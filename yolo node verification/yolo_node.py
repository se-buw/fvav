#!/usr/bin/env python3
import os
import time
import threading
import sys
from pathlib import Path


sys.path.append(str(Path(__file__).resolve().parent / "yolo_sign_node_dafny-py"))

try:
    import module_
    import _dafny
    _DAFNY_OK = True
except ImportError:
    module_ = None
    _dafny = None
    _DAFNY_OK = False


def dafny_class_to_cmd(c: str) -> str:
    """Call the formally-verified Dafny ClassToCmd across the language boundary.
    Returns a native Python str command, or "" for an unmapped class.
    """
    arg = _dafny.Seq(map(_dafny.CodePoint, c))
    result = module_.default__.ClassToCmd(arg)
    # Collapse the returned Seq of CodePoints back into a native Python str.
    return result.VerbatimString(False)


def dafny_best_detection(detections, conf_thres):
    """Run the formally-verified argmax (Dafny BestDetection) over detections.
    Returns (best_conf: float, best_name: str | None)
    """
    box_seq = [
        module_.Box_Box(_dafny.BigRational(conf),
                        _dafny.Seq(map(_dafny.CodePoint, name)))
        for conf, name in detections
    ]
    best_conf, best_name = module_.default__.BestDetection(
        box_seq, _dafny.BigRational(conf_thres))
    name = best_name.VerbatimString(False)
    return float(best_conf), (name if name else None)


import rclpy
from rclpy.node import Node
from rclpy.qos import qos_profile_sensor_data

from sensor_msgs.msg import CompressedImage
from std_msgs.msg import String

import numpy as np
import cv2
from ultralytics import YOLO


class YoloSignNode(Node):
    def __init__(self):
        super().__init__("yolo_sign_node")

        # Parameters
        self.declare_parameter("model_path", "")
        self.declare_parameter("image_topic", "/image_raw/compressed")
        self.declare_parameter("conf_thres", 0.15)
        self.declare_parameter("imgsz", 320)
        self.declare_parameter("publish_topic", "/direction_cmd")
        self.declare_parameter("log_every_n", 30)
        self.declare_parameter("skip_frames", 3)

        self.model_path = self.get_parameter("model_path").value
        self.image_topic = self.get_parameter("image_topic").value
        self.conf_thres = float(self.get_parameter("conf_thres").value)
        self.imgsz = int(self.get_parameter("imgsz").value)
        self.publish_topic = self.get_parameter("publish_topic").value
        self.log_every_n = int(self.get_parameter("log_every_n").value)
        self.skip_frames = int(self.get_parameter("skip_frames").value)

        if not self.model_path:
            self.get_logger().error("model_path is empty. Pass -p model_path:=/full/path/to/model.pt")
            raise RuntimeError("model_path empty")

        if not os.path.exists(self.model_path):
            self.get_logger().error(f"Model not found: {self.model_path}")
            raise FileNotFoundError(self.model_path)

        # Load YOLO model
        self.get_logger().info(f"Loading YOLO model: {self.model_path}")
        self.model = YOLO(self.model_path, task="detect")
        self.get_logger().info(f"Model class names: {self.model.names}")

        # Publisher and Subscriber
        self.pub = self.create_publisher(String, self.publish_topic, 10)
        self.sub = self.create_subscription(
            CompressedImage,
            self.image_topic,
            self.image_cb,
            qos_profile_sensor_data,
        )

        # Shared frame buffer
        self._lock = threading.Lock()
        self._latest_frame = None
        self._latest_stamp = time.time()

        # State
        self._frame_count = 0
        self._last_cmd = None
        self._last_cmd_time = 0.0

        # Worker thread for inference
        self._running = True
        self._worker = threading.Thread(target=self.inference_loop, daemon=True)
        self._worker.start()

        # Health check timer
        self.create_timer(2.0, self.health_check)

        self.get_logger().info(f"✓ Subscribed to: {self.image_topic}")
        self.get_logger().info(f"✓ Publishing to: {self.publish_topic}")
        self.get_logger().info(f"✓ Confidence threshold: {self.conf_thres}")
        self.get_logger().info(f"✓ Image size: {self.imgsz}")
        self.get_logger().info(f"✓ Frame skip: {self.skip_frames}")
        if _DAFNY_OK:
            self.get_logger().info("✓ class_to_cmd: using formally-verified Dafny module")
        else:
            self.get_logger().warn("Dafny module not found; using local Python class_to_cmd fallback")
        self.get_logger().info("YOLO Sign Node is ready!")

    def destroy_node(self):
        self._running = False
        try:
            self._worker.join(timeout=1.0)
        except Exception:
            pass
        super().destroy_node()

    def health_check(self):
        dt = time.time() - self._latest_stamp
        if dt > 3.0:
            self.get_logger().warn(
                f"No images received for {dt:.1f}s on {self.image_topic}"
            )

    def image_cb(self, msg: CompressedImage):
        # Skip frames for CPU optimization
        self._frame_count += 1
        if self._frame_count % self.skip_frames != 0:
            return
        
        # Decode compressed image
        np_arr = np.frombuffer(msg.data, dtype=np.uint8)
        frame = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        if frame is None:
            self.get_logger().warn("Failed to decode compressed image.")
            return

        # Store frame for processing
        with self._lock:
            self._latest_frame = frame
            self._latest_stamp = time.time()

        if self._frame_count % self.log_every_n == 0:
            self.get_logger().info(f"Receiving images... frame={self._frame_count}")

    def inference_loop(self):
        while self._running and rclpy.ok():
            frame = None
            with self._lock:
                if self._latest_frame is not None:
                    frame = self._latest_frame.copy()

            if frame is None:
                time.sleep(0.05)
                continue

            # Run YOLO inference
            results = self.model(frame, imgsz=self.imgsz, verbose=False)
            boxes = results[0].boxes

            if boxes is None or len(boxes) == 0:
                time.sleep(0.05)
                continue

            # Extract (conf, name) for each YOLO box.
            detections = []
            for b in boxes:
                conf = float(b.conf.item())
                cls_idx = int(b.cls.item())
                name = self.model.names.get(cls_idx, str(cls_idx)) or str(cls_idx)
                detections.append((conf, name))

            # Priotizes dafny verified best detection, 
            # falls back if dafny compile error
            if _DAFNY_OK:
                best_conf, best_name = dafny_best_detection(detections, self.conf_thres)
            else:
                best_conf, best_name = self.best_detection(detections, self.conf_thres)

            if best_name is None:
                time.sleep(0.05)
                continue

            # Priotizes dafny verified class_to_cmd, 
            # falls back if dafny compile error
            c = str(best_name).strip().lower()
            if _DAFNY_OK:
                cmd = dafny_class_to_cmd(c)
            else:
                cmd = self.class_to_cmd(c) or ""

            if not cmd:
                self.get_logger().warn(f"Unmapped class: '{best_name}' (conf {best_conf:.2f})")
                time.sleep(0.05)
                continue

            # Publish command if changed
            now = time.time()
            if cmd != self._last_cmd or (now - self._last_cmd_time) > 4.0:
                out = String()
                out.data = cmd
                self.pub.publish(out)
                self._last_cmd = cmd
                self._last_cmd_time = now
                self.get_logger().info(f"Detected: {best_name} ({best_conf:.2f}) -> {cmd}")

            time.sleep(0.05)

    def best_detection(self, detections, conf_thres):
        """Python fallback mirroring Dafny BestDetection: argmax conf >= thres.

        Returns (best_conf: float, best_name: str | None).
        """
        best_conf = 0.0
        best_name = None
        for conf, name in detections:
            if conf >= conf_thres and conf > best_conf:
                best_conf = conf
                best_name = name
        return best_conf, best_name

    def class_to_cmd(self, classname: str):
        """Map YOLO class name to direction command"""
        c = str(classname).strip().lower()

        if "left" in c:
            return "LEFT"
        if "right" in c:
            return "RIGHT"
        if "stop" in c:
            return "STOP"
        if "straight" in c:
            return "STRAIGHT"
        if "u" in c and "turn" in c:
            return "U_TURN"

        return None
        


def main():
    rclpy.init()
    node = YoloSignNode()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    node.destroy_node()
    rclpy.shutdown()


if __name__ == "__main__":
    main()
