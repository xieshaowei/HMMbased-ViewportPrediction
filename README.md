# HMMbased-ViewportPrediction
HMM based Viewport Prediction Algorithm.
This HMM based viewport prediction algorithm was written by Yunqiao Li and Shaowei Xie (2019), from Shanghai Jiao Tong University. See the paper "Perceptually Optimized Quality Adaptation of Viewport-Dependent Omnidirectional Video Streaming" for more details.

1) heatCenter.m: get the center of most salient areas.
2) velocityAve.m: get the average velocities (Output Tokens), as the as the hidden state of every T frames.
3) GMMinit.m: initialization of GMM model.
4) predHMM_train.m: training of the HMM algorithm for viewport prediction.
5) predHMM_test.m: validation of the HMM algorithm for viewport prediction.
