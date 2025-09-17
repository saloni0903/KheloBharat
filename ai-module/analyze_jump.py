import cv2
import mediapipe as mp
import numpy as np

def calculate_angle(a, b, c):
    a = np.array(a)  # First
    b = np.array(b)  # Mid
    c = np.array(c)  # End
    radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(a[1] - b[1], a[0] - b[0])
    angle = np.abs(radians * 180.0 / np.pi)
    if angle > 180.0:
        angle = 360 - angle
    return angle

def analyze_jump_robust(video_path):
    mp_pose = mp.solutions.pose
    pose = mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)

    cap = cv2.VideoCapture(video_path)
    jump_count = 0
    in_jump_motion = False
    max_hip_y = 0
    min_hip_y = 1
    
    # Store keypoint data for proof clip and scoring
    all_hip_y = []
    
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = pose.process(image)
        
        if results.pose_landmarks:
            landmarks = results.pose_landmarks.landmark
            
            # Use hip keypoints for vertical movement tracking
            left_hip = [landmarks[mp_pose.PoseLandmark.LEFT_HIP].x, landmarks[mp_pose.PoseLandmark.LEFT_HIP].y]
            right_hip = [landmarks[mp_pose.PoseLandmark.RIGHT_HIP].x, landmarks[mp_pose.PoseLandmark.RIGHT_HIP].y]
            
            hip_y = (left_hip[1] + right_hip[1]) / 2
            all_hip_y.append(hip_y)

            # Squat detection: Check hip and knee angles
            left_knee = [landmarks[mp_pose.PoseLandmark.LEFT_KNEE].x, landmarks[mp_pose.PoseLandmark.LEFT_KNEE].y]
            left_ankle = [landmarks[mp_pose.PoseLandmark.LEFT_ANKLE].x, landmarks[mp_pose.PoseLandmark.LEFT_ANKLE].y]
            left_hip_angle = calculate_angle(left_ankle, left_knee, left_hip)
            
            # Simple jump state machine
            if hip_y > max_hip_y:
                max_hip_y = hip_y  # Tracking the lowest point of the squat
            
            # Detect lift-off from squat
            if hip_y < max_hip_y - 0.05 and left_hip_angle > 160: # Thresholds for vertical movement and straight legs
                if not in_jump_motion:
                    in_jump_motion = True
            
            # Detect landing
            if in_jump_motion and hip_y > max_hip_y - 0.02:
                jump_count += 1
                in_jump_motion = False
                max_hip_y = hip_y # Reset baseline
            
            # For proof clip generation, you'd save frames with a high hip velocity or peak height.
            # (Logic for this is more complex and best done in the mobile app where the video is)

        cv2.imshow('Jump Detector', cv2.cvtColor(image, cv2.COLOR_RGB2BGR))
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
    
    return jump_count

if __name__ == '__main__':
    video_file = 'sample_video.mp4'
    count = analyze_jump_robust(video_file)
    print(f"Total Jumps Detected (Robust): {count}")