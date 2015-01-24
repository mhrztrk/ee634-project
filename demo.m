
% Add toolbox for Subpixel Motion Estimation
addpath(strcat(pwd, '/SubME_1.6/'));

test_images = {...
'./DataSet/foreman_cif.y4m', ...    
'./DataSet/coastguard_cif.y4m', ...
'./DataSet/carphone_qcif.y4m', ...
'./DataSet/mother_daughter_cif.y4m', ...
'./DataSet/salesman_qcif.y4m', ...
'./DataSet/mobile_cif.y4m', ...
'./DataSet/claire_qcif.y4m'};

opts.BlockSize   = 8;
opts.SearchLimit = 16;
opts.SearchMethod = 'Log';
%opts.SearchMethod = 'Full';


for i=1:length(test_images)

    opts.ExpandRatio = 0.8;
    opts.Interpolation = 'Taylor';
    PSNR{i,1} = video_interpolation(test_images{i}, opts);
    
    opts.ExpandRatio = 1.0;
    opts.Interpolation = 'None';
    PSNR{i,2} = video_interpolation(test_images{i}, opts);
    
    opts.Interpolation = 'HalfPixel';
    PSNR{i,3} = video_interpolation(test_images{i}, opts);
    
    opts.Interpolation = 'QuarterPixel';
    PSNR{i,4} = video_interpolation(test_images{i}, opts);
    
    opts.Interpolation = 'SemiQuarterPixel';
    PSNR{i,5} = video_interpolation(test_images{i}, opts);
end

%% Draw PSNR curves

psnr_mat_files = {
    'foreman_cif', ...
    'coastguard_cif', ...
    'carphone_qcif', ....
    'mother_daughter_cif', ...
    'salesman_qcif', ...
    'mobile_cif', ...
    'claire_qcif'};


for i=1:length(psnr_mat_files)
    S = load(sprintf('psnr_%s_None.mat', psnr_mat_files{i}), 'PSNR'); PSNR{i,1} = S.PSNR;
    S = load(sprintf('psnr_%s_HalfPixel.mat', psnr_mat_files{i}), 'PSNR'); PSNR{i,2} = S.PSNR;
    S = load(sprintf('psnr_%s_QuarterPixel.mat', psnr_mat_files{i}), 'PSNR'); PSNR{i,3} = S.PSNR;
    S = load(sprintf('psnr_%s_SemiQuarterPixel.mat', psnr_mat_files{i}), 'PSNR'); PSNR{i,4} = S.PSNR;
    S = load(sprintf('psnr_%s_Taylor', psnr_mat_files{i}), 'PSNR'); PSNR{i,5} = S.PSNR;
    
    infmap = isinf(PSNR{i,1}) | isinf(PSNR{i,5}); 
    for j=1:2
        PSNR{i,j} = PSNR{i,j}(~infmap);
    end
    
    nFrames = 20; 
    
     % Figure - 1 (Subpixel(Taylor) vs Integer ME)
     fig1 = figure('units', 'normalized', 'outerposition', [0 0 1/2 1/2]);
     
     % Create axes
     axes1 = axes('Parent',fig1,'YGrid','on','XGrid','on'), box(axes1,'on'), hold(axes1,'all');
 
     % Create multiple lines using matrix input to plot
     YMatrix1 = [PSNR{i,1}(1:nFrames);PSNR{i,2}(1:nFrames)]';
    
     plot1 = plot(YMatrix1,'Parent',axes1,'LineStyle',':');
     set(plot1(1),'MarkerFaceColor',[0 0 1],'Marker','o','Color',[0 0 1], ...
         'DisplayName','None');
     set(plot1(2),'MarkerFaceColor',[1 0 0],'Marker','square','Color',[1 0 0], ...
         'DisplayName','Taylor');
 
     xlabel('Frame Number'), ylabel('PSNR'),legend(axes1,'show');
    
    % Figure - 2 (Subpixel(Taylor) vs Half,Quarter,HalfQuarter)
    fig1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    
    % Create axes
    axes1 = axes('Parent',fig1,'YGrid','on','XGrid','on'), box(axes1,'on'), hold(axes1,'all');

    % Create multiple lines using matrix input to plot
    YMatrix1 = [PSNR{i,2}(1:nFrames);PSNR{i,3}(1:nFrames);...
        PSNR{i,4}(1:nFrames);PSNR{i,5}(1:nFrames)]';
   
    plot1 = plot(YMatrix1,'Parent',axes1,'LineStyle',':');
    set(plot1(1),'MarkerFaceColor',[1 0 0],'Marker','square','Color',[1 0 0],...
        'DisplayName','Half-pixel');
    set(plot1(2),'MarkerFaceColor',[0 0 1],'Marker','o','Color',[0 0 1], ...
        'DisplayName','Quarter-pixel');
    set(plot1(3),'MarkerFaceColor',[0 0.5 0.5],'Marker','v','Color',[0 0.5 0.5], ...
        'DisplayName','HalfQuarter-pixel');
    set(plot1(4),'MarkerFaceColor',[0.7 0.7 0],
    'Marker','pentagram','Color',[0.7 0.7 0], ...
        'DisplayName','Taylor');
    
    xlabel('Frame Number'), ylabel('PSNR'),legend(axes1,'show');
 
    
     % Figure - 3 (All)
     fig1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
     
     % Create axes
     axes1 = axes('Parent',fig1,'YGrid','on','XGrid','on'), box(axes1,'on'), hold(axes1,'all');
 
     % Create multiple lines using matrix input to plot
     YMatrix1 = [PSNR{i,1}(1:nFrames);PSNR{i,2}(1:nFrames);PSNR{i,3}(1:nFrames);...
         PSNR{i,4}(1:nFrames);PSNR{i,5}(1:nFrames)]';
    
     plot1 = plot(YMatrix1,'Parent',axes1,'LineStyle',':');
     set(plot1(1),'MarkerFaceColor',[0 0 1],'Marker','o','Color',[0 0 1], ...
         'DisplayName','None');
     set(plot1(2),'MarkerFaceColor',[1 0 0],'Marker','square','Color',[1 0 0],...
         'DisplayName','Half-pixel');
     set(plot1(3),'MarkerFaceColor',[1 0 0],'Marker','v','Color',[1 0.7 0.4], ...
         'DisplayName','Quarter-pixel');
     set(plot1(4),'MarkerFaceColor',[1 0 0],'Marker','+','Color',[0 0.5 0.5], ...
         'DisplayName','HalfQuarter-pixel');
     set(plot1(5),'MarkerFaceColor',[1 0 0],'Marker','pentagram','Color',[0.7 0.7 0], ...
         'DisplayName','Taylor');
     
     xlabel('Frame Number'), ylabel('PSNR'),legend(axes1,'show');
end
    
%% Single Frame Analysis
% Parameters
opts.BlockSize   = 8;
opts.SearchLimit = 16;
opts.SearchMethod = 'Log';
%opts.SearchMethod = 'Full';

opts.ExpandRatio = 0.8;
opts.Interpolation = 'Taylor';
[mcframe1, psnr1] = frame_interpolation(test_images{1}, 16, opts);

opts.ExpandRatio = 1.0;
opts.Interpolation = 'None';
[mcframe2, psnr2] = frame_interpolation(test_images{1}, 15, opts);

opts.Interpolation = 'HalfPixel';
[mcframe3, psnr3] = frame_interpolation(test_images{1}, 15, opts);

opts.Interpolation = 'QuarterPixel';
[mcframe4, psnr4] = frame_interpolation(test_images{1}, 15, opts);

opts.Interpolation = 'SemiQuarterPixel';
[mcframe5, psnr5] = frame_interpolation(test_images{1}, 15, opts);


