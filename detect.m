if ~exist('cam', 'var')
    cam=webcam; % use one of webcam(1), webcam(2), and so on if there are multiple webcams
    cam.Resolution='640x480';
end
k = 0;
i = 0;
feature('DefaultCharacterSet', 'UTF8');
slCharacterEncoding('UTF-8');

label_set = zeros(1, 40);
word_array = strings(1, 300);
% noun
word_array(1) = "I";
word_array(2) = "you";
word_array(3) = "that";
word_array(4) = "friend";
word_array(5) = "sister";
word_array(6) = "home";
word_array(7) = "icecream";
% adjective
word_array(101) = "angry";
word_array(102) = "okay";
word_array(103) = "right";
word_array(104) = "happy";
% verb
word_array(201) = "dislike";
word_array(202) = "love";
word_array(203) = "promise";
word_array(204) = "come";
word_array(205) = "like";
word_array(206) = "eat";

prev_most_common = 0;
% for sentence
word_count = 0;
word_num = zeros(1, 10);    % array of word label number 
word_set = strings(1, 10);
    
while 1
    im=snapshot(cam);
    % Pre-process the images as required for the CNN
    
    img = imresize(im, net.Layers(1).InputSize(1:2));
    
    % Extract image features using the CNN
    imageFeatures = activations(net, img, featureLayer, 'OutputAs', 'columns');
    % Make a prediction using the classifier
    [label,scores] = predict(classifier, imageFeatures, 'ObservationsIn', 'columns');
    
    if(label == 'blank')
        index = 0;
    elseif(label == 'I')
        index = 1;
    elseif(label == 'you')
        index = 2;
    elseif(label == 'that')
        index = 3;
    elseif(label == 'friend')
        index = 4;
    elseif(label == 'sister')
        index = 5;
    elseif(label == 'home')
        index = 6;
    elseif(label == 'icecream')
        index = 7;
    elseif(label == 'angry')
        index = 101;
    elseif(label == 'okay')
        index = 102;
    elseif(label == 'right')
        index = 103;
    elseif(label == 'happy')
        index = 104;
    elseif(label == 'dislike')
        index = 201;
    elseif(label == 'love')
        index = 202;
    elseif(label == 'promise')
        index = 203;
    elseif(label == 'come')
        index = 204;
    elseif(label == 'like')
        index = 205;
    elseif(label == 'eat')
        index = 206;
    end
    
    label_set(mod(k,40)+1) = index;
    imshow(im)
    text(30,30,sprintf('%s', label))
%     text(70,100,sprintf('%s', string(label_set(mod(k,40)+1))))
%     text(220,100,sprintf('test num: %d', k))
    text(200,30,sprintf('word num: %d', word_count))
%     text(30,60,sprintf('%f ',scores))

    [most_common, times] = mode(label_set(:));
    
    if (most_common == 0)
        if (word_count > 0)
            if (word_count == 1)
                text(250, 400, sprintf('%s', string(word_set(1))), 'FontSize',20)
                pause(1);
                word_count = 0;
            elseif (word_count == 2)
                if (word_num(2) > 100 && word_num(2) < 200)
                    word_set(3) = word_set(2);
                    if (word_num(1) == 1)
                        word_set(2) = 'am'
                    elseif (word_num(1) == 2)
                        word_set(2) = 'are'
                    else 
                        word_set(2) = 'is'
                    end
                    text(180, 400, sprintf('%s %s %s', string(word_set(1)), string(word_set(2)), string(word_set(3))),'FontSize',20)
                    pause(1);
                    sentence = strcat(word_set(1), " ",word_set(2), " ", word_set(3));
                    if (sentence == 'I am happy')
                        tts('I am happy');
                    elseif (sentence == 'Sister is angry')
                        tts('Sister is angry');
                    end
                else
                    text(210, 400, sprintf('%s %s', string(word_set(1)), string(word_set(2))), 'FontSize',20)
                    pause(1);
                end 
                word_count = 0;
            elseif (word_count == 3)
                if (word_num(2) < 100 && word_num(3) > 100)
                    if(word_num(2) ==1)
                        word_set(2) = "me";
                    end
                    text(180,400, sprintf('%s %s %s', string(word_set(1)), string(word_set(3)), string(word_set(2))), 'FontSize',20)
                else
                    if(word_num(3) ==1)
                        word_set(3) = "me";
                    end
                    text(180, 400, sprintf('%s %s %s', string(word_set(1)), string(word_set(2)), string(word_set(3))), 'FontSize',20)
                end
                pause(1);
                sentence = strcat(word_set(1), " ",word_set(2), " ", word_set(3));
                if (sentence == 'You come home')
                    tts('You come home');
                elseif (sentence == 'I like icecream')
                    tts('I like icecream');
                elseif (sentence == 'You promise me')
                    tts('You promise me');
                end
                word_count = 0;
    %        break;
            end
        end
 
    else
        most_common_word = word_array(most_common);
        word_percent = times / numel(label_set);
        threshold = 0.5;
        if (word_percent > threshold)
            text(30,70, sprintf('recognized word: %s',(most_common_word)))
            if (prev_most_common ~= most_common) 
                word_set(word_count+1) = most_common_word;
                word_num(word_count+1) = find(word_array == most_common_word);
                word_count = word_count + 1;
            end
            if (word_count > 3)
                word_set = strings(1, 3);
                word_count =  0;
            end
            prev_most_common = most_common;
        end     
    end
  
    drawnow
    pause(0.05);
    k = k + 1;
end
