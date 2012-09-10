function [tp,fp,fn]=getRoc(pidx,GT)
% pidx: picked peaks' index.
% GT: ground truth.

tp=0; fp=0; fn=0;
% For simudata verification.

offset=2;
%     dataLen=100000;
%     totalNum=dataLen;
t=1;
if length(GT)>1
    g=GT;
else
    %         g=(30:5000:dataLen); % ground truth.
    disp('Error: length of GT = 1!');
    return;
end
for i=1:length(g)
    if numel(pidx)==0 % There is no peak picked.
        fp=0;
        tp=0;
        break;
    end
    while pidx(t)<g(i)-offset
        fp=fp+1;
        t=t+1;
        if t>length(pidx)
            t=t-1;
            break;
        end
    end
    if pidx(t)>=g(i)-offset && pidx(t)<=g(i)+offset % tp.
        tp=tp+1;
        t=t+1;
        if t>length(pidx)
            t=t-1;
            break;
        end
    elseif pidx(t)>g(i)+offset % fn.
        fn=fn+1;
    end
end
if t<length(pidx)
    fp=fp+length(pidx)-t;
end
fn=length(g)-tp;

%     ROC: tpr vs fpr
%     TPR = TP / P = TP / (TP + FN)
%     FPR = FP / N
%     tpr = tp/(length(pidx)); % This is wrong version.
%     tpr = tp/(length(g));
%     fpr = fp/(totalNum-length(g));
fprintf(1,'TP: %f\n',tp);
fprintf(1,'FP: %f\n',fp);
fprintf(1,'FN: %f\n',fn);
% else
%     disp('No simuData, so fpr and tpr are 0.');
end