function [feas, xOpt, uOpt,JOpt] = Planner_MPC_Noa(u2d,u1d,qx,rou1,rou2,Tx,x0, M, N,Q, R, xL, xU, uL, uU,obstacle,safetyR)
%carry out MPC on a simulation horizon of M
feas=zeros(1,M);
xOpt=zeros(size(Q,2),M+1);xOpt(:,1)=x0;
uOpt=zeros(size(R,2),M);
JOpt=zeros(1,M);
pred=zeros(size(Q,2),N+1,M+1);
K=1;
for i = 1:M
[feas(i), xIter,uIter, JIter] = Planner_BatchforMPC_Noa(u2d,u1d,qx,rou1,rou2,Tx,i,Q, R, N, x0, xL, xU, uL, uU,obstacle,safetyR);
if feas(i)==false
    for t= i+1:M
        feas(t)=false;
    end
%     xOpt=[];
%     uOpt=[];
% %     predErr=[];
    return
end
x0=xIter{end}(:,2);
xOpt(:,i+1)=x0;
JOpt(i)=JIter{end};
uOpt(i)=uIter{end}(1);
for t=1:N+1
    pred(:,t,i)=xIter{end}(:,t);
end
feas = logical(feas);
fprintf('Time step %d is done \n',K)
fprintf('############################################ \n')
K=K+1;
end

% %calculating prediction error 
% predErr=zeros(2,M-N+1);
% DifferenceX1=zeros(1,N-1);
% DifferenceX2=zeros(1,N-1);
% for i=1:M-N+1
%     for t=1:N-1
%         DifferenceX1(t)= pred(1,t+2,i)-xOpt(1,i+t+1);
%         DifferenceX2(t)= pred(2,t+2,i)-xOpt(2,i+t+1);
%     end
% predErr(1,i)=norm(DifferenceX1);
% predErr(2,i)=norm(DifferenceX2);
% end

%plot 
figure
plot(xOpt(1,:),xOpt(2,:),'-o')
xlabel('x1');
ylabel('x2');
hold on
for i=1:M+1
    plot(pred(1,:,i),pred(2,:,i),'--')
end
% title(['N=' num2str(N)])
legend('Closed_loop trajectory','N step prediction at each time')
viscircles([obstacle(1) obstacle(2)],safetyR+obstacle(3))
viscircles([obstacle(1) obstacle(2)],obstacle(3))
viscircles([obstacle(4) obstacle(5)],safetyR+obstacle(6))
viscircles([obstacle(4) obstacle(5)],obstacle(6))
viscircles([obstacle(7) obstacle(8)],safetyR+obstacle(9))
viscircles([obstacle(7) obstacle(8)],obstacle(9))
viscircles([obstacle(10) obstacle(11)],safetyR+obstacle(12))
viscircles([obstacle(10) obstacle(11)],obstacle(12))
hline1=refline(0,4.5);
hline2=refline(0,1.5);
hline3=refline(0,-1.5);
hline4=refline(0,-4.5);
hline1.Color = 'k';
hline2.Color = 'k';
hline3.Color = 'k';
hline4.Color = 'k';
axis equal
hold off

% %plot wrt time
% figure(2)
% t=0:1:M;
% plot(t,xOpt(1,M+1),t,xOpt(2,M+1))
% hold on
% t=[0,1,2,3];
% for i=1:M+1
%     plot(t,pred(1,:,i),'--',t,pred(2,:,i),'--')
%     t=t+ones(1,4);
% end
% hold off
end