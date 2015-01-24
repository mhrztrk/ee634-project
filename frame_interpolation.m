function [ mcframe, PSNR ] = frame_interpolation(input_file, frameidx, opts)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    if ~isfield(opts,'ExpandRatio')
        opts.ExpandRatio = 0.8;
    end
    
    % Input video object
    inputVideo = VideoReader(input_file);

    imgI_int = read(inputVideo, frameidx);
    imgB_int = read(inputVideo, frameidx+1);
    imgP_int = read(inputVideo, frameidx+2);
   
    % Read image

    imgI = im2double(imgI_int);
    imgB = im2double(imgB_int);
    imgP = im2double(imgP_int);

    % Motion estimation
    [MVx, MVy] = Bidirectional_ME2(imgI, imgP, opts);
    % Motion Compensation
    mcframe = reconstruct(imgI, MVx, MVy, opts.ExpandRatio);

    mcframe(mcframe>1) = 1;
    mcframe(mcframe<0) = 0;

    % Evaluation
    [M, N, C] = size(mcframe);
    Res  = mcframe-imgB(1:M, 1:N, 1:C);
    MSE  = norm(Res(:), 'fro')^2/numel(mcframe);
    PSNR = 10*log10(max(mcframe(:))^2/MSE);

    % Create figure
    fig1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);

    % Create subplot
    sp1 = subplot(2,2,1,'Visible','off','Parent',fig1);
    imshow(imgI, [], 'Parent',sp1);
    title('Previous Frame');

    % Create subplot
    sp2 = subplot(2,2,2,'Parent',fig1,'YTick', zeros(1,0), 'XTick',zeros(1,0));
    xlim(sp2,[0 (size(MVx,1)+1)]), ylim(sp2,[0 (size(MVy,1)+1)]), box(sp2,'on'), hold(sp2,'all');
    quiver(MVx(end:-1:1,:),MVy(end:-1:1,:),'AutoScaleFactor',0.9,'Parent',sp2);
    title('Motion Vector');

    % Create subplot
    sp3 = subplot(2,2,3,'Visible','off','Parent',fig1);
    imshow(mcframe, [], 'Parent', sp3);
    title('Motion Compansated Frame');

    % Create subplot
    sp4 = subplot(2,2,4,'Parent',fig1);
    imagesc(abs(imgI-mcframe), 'Parent', sp4);
    title(sprintf('Residual(%d) (PSNR = %.2f) (MSE = %.6f)', frameidx, PSNR, MSE));
    
end

