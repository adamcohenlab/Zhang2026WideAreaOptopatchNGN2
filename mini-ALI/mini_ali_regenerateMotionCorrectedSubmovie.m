% function submovie_corr = mini_ali_regenerateMotionCorrectedSubmovie(cropped_movie, coordinate, dfdx, dfdy, shift)
% % regenerateMotionCorrectedSubmovie
% %
% % Reconstruct motion-corrected submovie from raw movie and saved motion shift.
% %
% % INPUTS:
% %   cropped_movie       a spatial-crop of raw movie
% %   coordinate    left-up corner coordinate of cropped movie (x,y)
% %   colRange    cols to extract, e.g. 300:600
% %   frameRange  frames to extract, e.g. 1000:1200
% %   dfdx        H x W reference x-gradient
% %   dfdy        H x W reference y-gradient
% %   shift       2 x T motion coefficients
% %
% % OUTPUT:
% %   submovie_corr  motion-corrected submovie
% 
%     cropped_movie = single(cropped_movie);
%     sz = size(cropped_movie);
%     rowRange = coordinate(1):(coordinate(1)+sz(1)-1);
%     colRange = coordinate(2):(coordinate(2)+sz(2)-1);
% 
%     dfdx_sub = single(dfdx(rowRange, colRange));
%     dfdy_sub = single(dfdy(rowRange, colRange));
% 
%     submovie_corr = zeros(size(cropped_movie), 'single');
% 
%     for t = 1:sz(3)
%         motion_artifact = ...
%             dfdx_sub * shift(1,t) + ...
%             dfdy_sub * shift(2,t);
% 
%         submovie_corr(:,:,t) = cropped_movie(:,:,t) - motion_artifact;
%     end
% end
function submovie_corr = mini_ali_regenerateMotionCorrectedSubmovie(cropped_movie, coordinate, dfdx, dfdy, shift)

    cropped_movie = single(cropped_movie);
    sz = size(cropped_movie);

    rowRange = coordinate(1):(coordinate(1)+sz(1)-1);
    colRange = coordinate(2):(coordinate(2)+sz(2)-1);

    dfdx_sub = single(dfdx(rowRange, colRange));
    dfdy_sub = single(dfdy(rowRange, colRange));

    X = reshape(dfdx_sub, [], 1);
    Y = reshape(dfdy_sub, [], 1);

    motion_artifact = X * single(shift(1,1:sz(3))) + ...
                      Y * single(shift(2,1:sz(3)));

    movie_flat = reshape(cropped_movie, [], sz(3));
    submovie_corr = reshape(movie_flat - motion_artifact, sz);
end