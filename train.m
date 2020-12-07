% trained neural network to use
net=alexnet();

categories={'come', 'love', 'happy', 'blank', 'eat', 'you', 'angry', 'like', 'I', 'sister', 'that', 'home', 'friend', 'promise', 'icecream', 'okay','right', 'dislike'};
imds=imageDatastore(fullfile('sign_language',categories), 'LabelSource', 'foldernames');
tbl=countEachLabel(imds)
imds.ReadFcn = @(filename)readAndPreprocessImage(filename, net.Layers(1).InputSize(1:2));
[trainingSet, testSet] = splitEachLabel(imds, 0.7, 'randomize');

featureLayer = 'fc7';
trainingFeatures = activations(net, trainingSet, featureLayer, 'MiniBatchSize', 32, 'OutputAs', 'columns');

% Get training labels from the trainingSet
trainingLabels = trainingSet.Labels;

% Train multiclass SVM classifier using a fast linear solver, and set
% 'ObservationsIn' to 'columns' to match the arrangement used for training
% features.
classifier = fitcecoc(trainingFeatures, trainingLabels, ...
    'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');

% Extract test features using the CNN
testFeatures = activations(net, testSet, featureLayer, 'MiniBatchSize', 32, 'OutputAs', 'columns');

% Pass CNN image features to trained classifier
predictedLabels = predict(classifier, testFeatures, 'ObservationsIn', 'columns');

% Get the known labels
testLabels = testSet.Labels;

% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);

% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))

% Display the mean accuracy
mean(diag(confMat))
% 
%  for k=1:100
%      img = snapshot(cam);
%      image(img);
%      imwrite(img, sprintf('sign_language\\you\\image_%04d.jpeg', k), 'jpeg');
%      pause(0.25);
%  end
