% Simulation of an SEIQR-V Epidemic Model based on the Heterogeneous 
% Cellular Automata
%
% Zhou Lvwen: zhou.lv.wen@gmail.com
% December 1, 2014
%

xn = 100; yn = 100;      % grid size: [xn, yn] = size(people)
nsteps = 365;            % total time steps. unit: day

%%  seven state of people:
%   D: death             0 
%   S: suscerptible      1
%   E: ensconced         2
%   V: vaccination       3
%   I: infected          4
%   Q: quarantine        5
%   R: recovered         6

[D, S, E, V, I, Q, R] = deal(0, 1, 2, 3, 4, 5, 6);
num = zeros(nsteps, 7);       % number of seven type people.

%% probability & period           
Ps2r = 0.0;        Ts2r = 7;  % suscerptible to recovered
Pe2q = 0.400;      Te2q = 4;  % ensconced to quarantine
Pe2i = 0.25;                  % ensconced to infected
Pi2q = 0.800;      Ti2q = 7;  % vaccination to infected
Pi2d = 0.002;                 % vaccination to death
Pq2d = 0.00625;               % quarantine to death
Pq2r = 0.998;      Tq2r = 7;  % quarantine to recovered
Pv2r = 0.85;                  % vaccination to revovered
Pr2s = 0.8;        Tr2s = 365;% recovered to suscerptible

%% init state of people array.
ppl = ones(xn, yn);      % people array
ppl(50,50) = E;
time = zeros(size(ppl)); % time: to record the duration of each state

%% orientation
north = [yn, 1:yn-1]; south = [2:yn, 1];
east  = [xn, 1:xn-1]; west  = [2:xn, 1];
%% distance of each orientation
dis = sqrt([ 2   1   2 ...
             1       1 ...
             2   1   2 ]);

%%
figure('position',[50,50,1200,400])

subplot(1,2,1)
hi = imagesc(ppl,[D,R]); colorbar;

subplot(1,2,2)
str={'r-','b-','k-','m-','r--','b--','k--'};
for i = 1:7
   h(i) =  plot(1:nsteps, num(:,i),str{i}); hold on;
end
legend('D', 'S', 'E', 'V', 'I', 'Q', 'R');  axis([0, nsteps, 0, xn*yn])

for t = 1:nsteps
    time = time + 1;
    
    nab(:,:,1) = ppl(north,east);   nab(:,:,2) = ppl(north,:);   nab(:,:,3) = ppl(north,west);
    nab(:,:,4) = ppl(  :  ,east);         pplt = ppl;            nab(:,:,5) = ppl(  :  ,west);
    nab(:,:,6) = ppl(south,east);   nab(:,:,7) = ppl(south,:);   nab(:,:,8) = ppl(south,west);
    
    powE = unifrnd(0.0, 0.5, xn, yn);
    powI = unifrnd(0.5, 1.0, xn, yn);
    resS = unifrnd(0.0, 1.0, xn, yn);
    
    Ps2e = zeros(size(ppl)); % probability of suscerptible to ensconced
    for i = 1:8
        probi = (nab(:,:,i)==E).* sqrt(dis(i).*powE.*(1-resS)) + ...
                (nab(:,:,i)==I).* sqrt(dis(i).*powI.*(1-resS));
        Ps2e = max(Ps2e, probi);
    end
    
    ppl( pplt==S & rand(xn,yn)<Ps2e                       ) = E;
    ppl( pplt==S & rand(xn,yn)<Ps2r & time>=Ts2r & ppl==S ) = R;
    
    ppl( pplt==E & rand(xn,yn)<Pe2q & time< Te2q          ) = Q;
    ppl( pplt==E & rand(xn,yn)<Pe2i & time>=Te2q & ppl==E ) = I;

    ppl( pplt==I & rand(xn,yn)<Pi2q & time< Ti2q          ) = Q;
    ppl( pplt==I & rand(xn,yn)<Pi2d & time>=Ti2q & ppl==I ) = D;
    
    ppl( pplt==Q & rand(xn,yn)<Pq2r & time>=Tq2r          ) = R;
    ppl( pplt==Q & rand(xn,yn)<Pq2d & time>=Tq2r & ppl==Q ) = D;
    
    ppl( pplt==R & rand(xn,yn)<Pr2s & time>=Tr2s          ) = S;
    
    time(ppl~=pplt) = 0;
    
    set(hi,'CData',ppl); 
    pplv = ppl(:);
    num(t,:) = sum([pplv==0 pplv==1 pplv==2 pplv==3 pplv==4 pplv==5 pplv==6]);
    for i = 1:7; set(h(i),'Xdata',1:t,'Ydata',num(1:t,i)); end
    drawnow
end