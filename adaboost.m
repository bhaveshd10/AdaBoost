clear all;clc;close all

% Define Mean and Covariance matrix
mean1=[0,0];
cov1=[1,0;0,1];
mean2=[0,-3];
cov2=[1,0;0,1];
mean3=[-3,3];
cov3=[1,0;0,1];
mean4=[3,3];
cov4=[1,0;0,1];

% Create Class1 and Class2
class1=mvnrnd(mean1,cov1,150);
class2a=mvnrnd(mean2,cov2,50);
class2b=mvnrnd(mean3,cov3,50);
class2c=mvnrnd(mean4,cov4,50);
class2=[class2a;class2b;class2c];

% Plot of class
figure,scatter(class1(:,1),class1(:,2))
hold on
scatter(class2(:,1),class2(:,2),'*','MarkerEdgeColor',[1 0 0])
grid on

% Label each class 1 or 0
label1(1:150,1)=1;
label2(1:150,1)=0;
class1=horzcat(class1,label1);
class2=horzcat(class2,label2);

% define weight and Probability
w(1:300)=1/300;
p=w;
W=w;
n=0;
% Multiply each class by weight
Y=[class1;class2];
Y=[Y,w'];
temp=Y;
C=zeros(length(Y),6);
C(:,1:4)=Y;
n=0;
error_forall=[];
while n<200
    line_chosen=[];err1=[];err2=[];d1=[];d2=[];
    for t=-4:0.1:4
        for i=1:length(Y)            
            % Check if above or below thresholf t in x 
            if Y(i,1)<t
                C(i,5)=0;
            else
                C(i,5)=1;
            end
            if Y(i,2)<t
                C(i,6)=0;       
            else
                C(i,6)=1;              
            end
        end        
        
        % Find all Missclassified points in x and y
        for i=1:length(C)
            if C(i,3)~=C(i,5)
                e1(i)=p(i)'.*(abs((C(i,3)-C(i,5))));
            else
                e1(i)=0;
            end
            if C(i,3)~=C(i,6)
                e2(i)=p(i)'.*(abs((C(i,3)-C(i,6))));
            else
                e2(i)=0;
            end
        end
        % check if sum of error for x and y is greater than 0.5
        if sum(e1)>0.5
            C(:,5)=abs(1-C(:,5));
            err1=[err1;[t,(1-sum(e1))]]; % if greater invert classifications
        else
            err1=[err1;[t,sum(e1)]];
        end
        if sum(e2)>0.5
            C(:,6)=abs(1-C(:,6));
            err2=[err2;[t,(1-sum(e2))]]; % if greater invert classifications
        else
            err2=[err2;[t,sum(e2)]];
        end        
        % append the classified labels for reference
        d1=[d1;C(:,5)'];
        d2=[d2;C(:,6)'];
        d=[d1;d2];
    end
    % Assign label to identify missclassification of class1 or class2
    x_label(1:length(err1))=1;
    y_label(1:length(err1))=2;

    % add label to error
    err1=[err1,x_label'];
    err2=[err2,y_label'];
    err=[err1;err2];
    % Find minimum error 
    [min_dimerror,location]=min(err(:,2));        

%     Plot the threshold 
    if err(location,3)==2
        yline(err(location,1));
    else
        xline(err(location,1));
    end
    % Calculate beta and update weight vector  
    beta=min_dimerror/(1+min_dimerror);    
    if err(location,3)==1
        C(:,5)=d(location,:)';
        for i=1:length(w)
            if (C(i,3)==C(i,5))
                C(i,4)=C(i,4).*beta;
            end
        end
    else
        C(:,6)=d(location,:)';
        for i=1:length(w)
            if (C(i,3)==C(i,6))
                C(i,4)=C(i,4).*beta;
            end
        end
    end
    % Find error for each classification
    error_forall=[error_forall;min_dimerror];
    % Update the Probability distribution
    for i=1:length(p)
        p(i)=C(i,4)./sum(C(:,4));
    end    
    n=n+1;   
end
hold off

for i=1:length(error_forall)
    a(i)=(1-error_forall(i))/error_forall(i);
end