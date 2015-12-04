/**
 * Program to solve mazes using mathematical morphology. 
 *
 * Based on the submission to Matlab File Exchange: 
 * http://www.mathworks.com/matlabcentral/fileexchange/27175-mazesolution
 */
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>

int main()
{
    cv::Mat src = cv::imread("maze.png");
    if (src.empty())
        return -1;

    cv::Mat bw;
    cv::cvtColor(src, bw, CV_BGR2GRAY);
    cv::threshold(bw, bw, 10, 255, CV_THRESH_BINARY_INV);

    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(bw, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);

    if (contours.size() != 2)
    {
        // "Perfect maze" should have 2 walls
        std::cout << "This is not a 'perfect maze' with just 2 walls!" << std::endl;
        return -1;
    }

    cv::Mat path = cv::Mat::zeros(src.size(), CV_8UC1);
    cv::drawContours(path, contours, 0, CV_RGB(255,255,255), CV_FILLED);

    cv::Mat kernel = cv::Mat::ones(19, 19, CV_8UC1); 
    cv::dilate(path, path, kernel);

    cv::Mat path_erode;
    cv::erode(path, path_erode, kernel);
    cv::absdiff(path, path_erode, path);

    std::vector<cv::Mat> channels;
    cv::split(src, channels);
    channels[0] &= ~path;
    channels[1] &= ~path;
    channels[2] |= path;

    cv::Mat dst;
    cv::merge(channels, dst);
    cv::imshow("solution", dst);
    cv::waitKey(0);

    return 0;
}
