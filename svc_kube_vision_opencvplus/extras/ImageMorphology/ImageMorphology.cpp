cv::Mat src = cv::imread("image.png", CV_LOAD_IMAGE_GRAYSCALE);
if (src.empty())
    return -1;

cv::normalize(src, src, 0, 1, cv::NORM_MINMAX);

cv::Mat dst;
dst = cv::Mat::zeros(src.size(), CV_8U);
dst.at<uchar>(75,75) = 1;

cv::Mat prev;
cv::Mat kernel = (cv::Mat_<uchar>(3,3) << 0, 1, 0, 1, 1, 1, 0, 1, 0);

do {
    dst.copyTo(prev);
    cv::dilate(dst, dst, kernel);
    dst &= (1 - src);
} 
while (cv::countNonZero(dst - prev) > 0);

cv::normalize(src, src, 0, 255, cv::NORM_MINMAX);
cv::normalize(dst, dst, 0, 255, cv::NORM_MINMAX);
