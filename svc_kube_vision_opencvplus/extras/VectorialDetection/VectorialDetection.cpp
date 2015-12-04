CvHistogram* wImage::getHistogram() {
    IplImage* gray = cvCreateImage(cvGetSize(this->image), 8, 1);

    CvHistogram* hist;
    int hist_size = 256;
    float range[] = {0, 256};
    float* ranges[] = {range};

    cvCvtColor(this->image, gray, CV_RGB2GRAY);
    hist = cvCreateHist(1, &hist_size, CV_HIST_ARRAY, ranges, 1);
    cvCalcHist(&gray, hist, 0, NULL);

    return hist;
}

bool wImage::isVectorial() {

    CvHistogram* hist = this->getHistogram();

    int height = 240;

    float max_value = 0, min_value = 0;
    cvGetMinMaxHistValue(hist, &min_value, &max_value);

    int total = 0;
    int colors = 0;

    float value;
    int normalized;

    for(int i=0; i < 256; i++){
        value = cvQueryHistValue_1D(hist, i);
        normalized = cvRound(value * height / max_value);

        if(normalized < 2 || normalized > 230) {
            continue;
        }

        colors++;
        total += normalized;
    }

    if((total < 500 && colors < 100) || (total < 1000 && colors < 85)) {
        return true;
    }

    return false;
}
