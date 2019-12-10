# HMMbased-ViewportPrediction
HMM based Viewport Prediction Algorithm.
This HMM based viewport prediction algorithm was written by Yunqiao Li and Shaowei Xie (2019), from Shanghai Jiao Tong University. See the paper "Perceptually Optimized Quality Adaptation of Viewport-Dependent Omnidirectional Video Streaming" for more details.

1) heatCenter.m: get the center of most salient areas.
--input: the original content feature maps, i.e., *_saliency.mp4 and *_motion.mp4 for each video.
--output: the position of heat center on the sphere, saved as many *_heatcen.mat.

2) velocityAve.m: get the average velocities (Output Tokens), as the hidden state of every T frames.
--input: (1)the head orientation information of each user for every video frame, which is recorded in *_orientation.xls; (2)the heat center data saved in *_heatcen.mat.
--output: the distance of the current viewpoint from the heat center, and the viewing speeds in different directions (i.e. yaw, pitch and roll), saved as many video*_user*.mat.

3) GMMinit.m: initialization of GMM model.
--input: all video*_user*.mat, for mathematical statistics.
--output: initial parameters of the GMM models for different hidden states in various directions (i.e. yaw, pitch and roll), saved as one Gaussian_init.mat.

4) predHMM_train.m: training of the HMM algorithm for viewport prediction.
--input: Gaussian_init.mat, for HMM training.
--output: necessary HMM parameters for viewport prediction, saved as one paramHMM_*.mat.

5) predHMM_test.m: validation of the HMM algorithm for viewport prediction.
--input: paramHMM_*.mat derived via training.
--output: the precision of viewport prediction.

Other related parameters are explained in the source codes.
