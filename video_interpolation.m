function [PSNR] = video_interpolation(input_file, opts, varargin)

if(length(varargin) <= 2)
    % No output file name specified
    [pathstr, name, ext] = fileparts(input_file);
    output_file = fullfile(pathstr, strcat(name,'_out', ext)); 
end

%------------------------ Video reading -----------------------------------

% Input video object
inputVideo = VideoReader(input_file);

% Create output video object
outputVideo = VideoWriter(output_file);
outputVideo.FrameRate = inputVideo.FrameRate;
open(outputVideo);

result_dir = sprintf('./result_bicubic/%s', name);
mkdir(result_dir);

nframes = 7;

if ~isfield(opts, 'Interpolation')
    opts.Interpolation = 'Taylor';
end

if (strcmp(opts.Interpolation, 'Taylor'))
    InterpolationLevel = 1;
elseif (strcmp(opts.Interpolation, 'HalfPixel'))
    InterpolationLevel = 2;
elseif (strcmp(opts.Interpolation, 'QuarterPixel'))
    InterpolationLevel = 4;
elseif (strcmp(opts.Interpolation, 'SemiQuarterPixel'))
    InterpolationLevel = 8; 
else
    InterpolationLevel = 1;
end

%---------------------- Create interpolated Frames ------------------------


opts.BlockSize = opts.BlockSize * InterpolationLevel;
opts.SearchLimit = opts.SearchLimit * InterpolationLevel;

for k=1:(nframes-1)

    imgI_int = read(inputVideo, k);
    imgB_int = read(inputVideo, k+1);

    % Read image
    imgI = im2double(imgI_int);
    imgB = im2double(imgB_int);

    tic

    imgI_expanded = imresize(imgI, InterpolationLevel, 'bicubic');
    imgB_expanded = imresize(imgB, InterpolationLevel, 'bicubic');

    % Motion estimation
    [MVx, MVy] = Bidirectional_ME(imgI_expanded, imgB_expanded, opts);
    % Motion Compensation
    imgMC_expanded = reconstruct(imgI_expanded, MVx, MVy, opts.ExpandRatio);

    imgMC = imresize(imgMC_expanded, 1/InterpolationLevel, 'bicubic');
    imgMC(imgMC>1) = 1;
    imgMC(imgMC<0) = 0;

    elapsed_time(k) = toc;

    % Evaluation
    [M, N, C] = size(imgMC);
    Res  = imgMC-imgB(1:M, 1:N, 1:C);
    MSE  = norm(Res(:), 'fro')^2/numel(imgMC);
    PSNR(k) = 10*log10(max(imgMC(:))^2/MSE);

    writeVideo(outputVideo,imgI);
    writeVideo(outputVideo,imgMC);

    res_title = sprintf('Residual(%d) (PSNR = %.2f) (MSE = %.6f) (Int: %s)', k, PSNR(k), MSE, opts.Interpolation);
    fig1 = CreateFigures(imgI, imgMC, MVx, MVy, res_title);
    saveas(fig1, sprintf('%s/%03d_%s.png', result_dir, k, opts.Interpolation));
    close(fig1); 

    fprintf('Completed: %d/%d\n', k, (nframes-1));
end    


save(sprintf('%s/psnr_%s_%s.mat', result_dir, name, opts.Interpolation), 'PSNR');
fprintf('%s (%s): Average Time = %f\n', name, opts.Interpolation, mean(elapsed_time));

close(outputVideo);

outputVideo = VideoReader(strcat(pathstr, '/', outputVideo.Filename));
mov(outputVideo.NumberOfFrames) = struct('cdata',[],'colormap',[]);
for ii = 1:outputVideo.NumberOfFrames
    mov(ii) = im2frame(read(outputVideo,ii));
end
set(gcf,'position', [150 150 outputVideo.Width outputVideo.Height])
set(gca,'units','pixels');
set(gca,'position',[0 0 outputVideo.Width outputVideo.Height])

image(mov(1).cdata,'Parent',gca);
axis off;
movie(mov,1,outputVideo.FrameRate);

end


function [fig1] = CreateFigures(imgI, imgMC, MVx, MVy, res_title)
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
    imshow(imgMC, [], 'Parent', sp3);
    title('Motion Compansated Frame');

    % Create subplot
    sp4 = subplot(2,2,4,'Parent',fig1);
    imagesc(abs(imgI-imgMC), 'Parent', sp4);
    title(res_title);
    
end

