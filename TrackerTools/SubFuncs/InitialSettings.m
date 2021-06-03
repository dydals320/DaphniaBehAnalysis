% 
% Define "Settings" structure containing all behavior segmentation
% settings. Open file to view definitions and [defaults]
%

Settings = struct(  'StallDistance', 0.59, ...       % Total Average speed 5.5mm/s --> 50% slower one: 2.75mm/s --> 0.59pixel (2.64*200/1280*20)
                    'FwdRunFr', 2.64, ...           % Total Average speed 5.5mm/s --> 50% faster one: 8.25mm/s --> 2.64pixel (2.64*200/1280*20)
                    'FrameRate', 25, ...            % Video framerate (frames/s) [2]
                    'PixelSize', 1280/200, ...      % Spatial calibration (pixels/mm) [36]
                    'FixJitter', true, ...          % obsolete
                    'MinPauseFrame', 5, ...         % Minimum number of frames as pause 
                    'SmoothWinSize', 100, ...        % Size of Window for smoothing track data (in frames) (1s) [3]
                    'SpinFrameWindow', 60, ...      % FrameWindow for Spin mode calculation (frame)
                    'MaxBodyPathAngleDev', 13, ...  % Max deviation (deg) of path vs body orientation in Fwd Run [13]
                    'MaxPathAngleDev', 11, ...      % Max deviation (deg) of path from 60deg for Fwd Run [11]
                    'MaxFwdRunEcc', 0.4, ...        % Max eccentricity for Fwd Run [0.4]
                    'MinFwdRunFr', 20, ...          % Min consecutive frames for 'real' Fwd Run (at least 1 s)
                    'MinRevAngVel', 259, ...        % (was 210) Min angular velocity (deg/s) for reversal [259]
                    'MaxShortTurnLen', 3, ...       % Max short turn (s) [3]
                    'MaxSmoothAngVel', 120, ...     % Maximum angular velocity for smooth, forward turns (deg/s) [120]
                    'MinPirEcc', 0.4, ...           % Min eccentricity for pirouette 'curl' state [0.4]
                    'MinPirEccTime', 2, ...         % Min time of eccentric 'curl' states (s) [2]
                    'MinErraticAngAcc', 200, ...    % Min angular acceleration for erratic movement (or swim) (deg/s^2) [200]
                    'MinErrTime', 6, ...            % Min time of erratic movements (s) [6]
                    'ErosionArea', 0.05, ...         % Percentage of errosion
                    'XBorderPadding', 0, ...        % Distance (pix) to shrink the selected tracking boundary [0]
                    'XBorderEffectTime', 2, ...     % Time (s) after crossing X-border to exclude [2]
                    'CollisionRelSize', 1.5, ...    % relative size threshold for collision detection [1.5]
                    'CollEffectTime', 5, ...        % Time (s) to ignore data after collision detection [5]
                    'BehDef', [ 1 1 1 1 7 2 6 7 4 8;  ... % Behavior code: 1-F, 2-FR, 3-Turn, 4-P, 5-OmR, 6-Omf, 7-?
                                3 3 3 3 7 3 5 7 4 8;  ...
                                4 4 4 4 4 4 4 4 4 8 ]);
                