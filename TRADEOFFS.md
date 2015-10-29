# Goals of the KUBE VISION cluster

## Tradeoffs:

1. Related to the input received:
        - Continous flow of pictures of various size of pictures and type (color, grayscale)
                - The processing needs to go fast
                - 98% of pictures are not matching a content (Hub, Connect)
                - 80% of pictures are related to a hand movement
        - Input pictures need to be resized to the same format (320x240)
                - Especially with SVM based, Computer vision system; they need to recieved an input with same characteristics as they have been trained
                - It can be applied to:
                        - Deeplearning (Caffe, Torch7)
                        - SVM Computer Vision
                        - OCR (text extraction)
                                - No aligned text are hard to be recognized
                        - Face, Hand-Detection
        - Input pictures can be detected as poorly featured up-front and save some resources [dark, blur]
                - It is not expensive to detect the following insights:
                        - Geometric shapes (Rectangle, Squares, Polygons, Rounds)
                        - Is the picture vectorial or real ?
                        - Extract exif informations (JPEG), Input orientation (Landscape, portrait)
                        - Detect nudity or skin
                        - Detect leather or any surfaces
        - Input pictures can require some image processing to improve pattern recognition
                - Sharpening a pictures
                - Adjust contrast
                - Adjust Gamma
                - Background extraction
        - Input pictures need to be saved in several copies for report generation (ELK/Neo4J)
                - A copy with the zone of interest cropped with the detected coordinates [x1, y1, x2, y2] with the same resolution [Per recognition frameworks]
                - A copy of the original input pictures as a reference
                - Link them by creating a token to cluster models/image datasets into a graph (http://iwct-gallery.dasgizmo.net/data/tide_v12/results/html/imagegraph.html?initial_image=000000000000016578$
        - Input pictures could require to cumulate several insights gathering
                - Real reflective product: Max Factor Colour Elixir Lipstick Burnt Caramel https://clicks.co.za/images/made/52e31d80ff74aec1/96021224_Marketing_AngleA15degree_1000_1000_80_int.jpg
                        - Challenges:
                                - Highly reflective
                                - The text is hard to distinguish
                                - Sensitive to light natural (artificial, natural)
                                - Loads of siblings present in the world
                        - Hypothesis:
                                1. Image Pre-processing
                                        a. Grayscale
                                        b. Sharpen
                                        c. Stroke-Width-Transform
                                2. Pattern recognition chain:
                                        a. SVM Computer Vision (Un-learning process)
                                        b. OCR Recognition
                                3. Results weighting with score moderation, and contextual analysis
                                        a. Geographic context
                                        b. Time Context
                                        c. Text Space projection
                - Hand and Face recognition
                        - Challenges:
                                - Sensitive to the background color noise
                                - Hard to get consistent results with features extraction
                        - Hypthesis:
                                1. Image Pre-processing
                                        a. Background removal
                                2. Pattern recognition chain:
                                        a. SVM Computer Vision
                                        b. Scene analysis (Distributed Deeplearning)
                                3. Results weighting with score moderation, and contextual analysis
                                        a. Scene Mining
                                        b. Time Context
                                        c. Text Space projection
