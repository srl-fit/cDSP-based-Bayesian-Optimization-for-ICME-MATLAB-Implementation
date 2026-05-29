rng(1)
URL = 27;
emi_target_Y = 3;

ndv = 1;
npoints = 5;

lb = [910];  
ub = [976];
designspace = [lb; ub];

X_lhs   = srgtsDOEOLHS(npoints, ndv, 'GA');
X_train = srgtsScaleVariable(X_lhs, [zeros(1, ndv); ones(1, ndv)], designspace);


a = [-659.23, 190.22, -17.802, 0.826910, ...
     -0.021885, 0.0003463, -3.2446e-6, ...
      1.6606e-8, -3.5757e-11];


f = @(x) ( (x - 900).^(0:8) ) * a.';   
%% Evaluate training outputs
Y_train = f(X_train);




n_eval = 60;
lhs_eval = srgtsDOEOLHS(n_eval, 1, 'GA');

lb_eval = [920];
ub_eval = [966];
designspace_eval = [lb_eval; ub_eval];


X_test = srgtsScaleVariable(lhs_eval, [zeros(1, 1); ones(1, 1)], designspace_eval);


max_iters = 15;





iteration = 1;

EI_progress = zeros(max_iters,1);
best_d_history = [];
emi_best_d_history = [];
y_best_d_history = [];
while iteration <= max_iters
    if isempty(X_test)
        fprintf('No more candidate test points left. Stopping.\n');
        break;
    end


    fprintf('\n--- Iteration %d ---\n', iteration);

    Model_test = FitGPModel(X_train, Y_train);

    
    X = X_train(:, 1);
    d_value = zeros(length(X), 1);
    emi_Y_value = zeros(length(X), 1);
    Y_mean_values = zeros(length(X), 1);
    
    for j = 1:length(X)
        X_input1 = normrnd(X(j), 5, [1000, 1]);
        X_input = ones(1000, 1);
        X_input(:, 1) = X_input1;
        [Y_mean, Y_var] = PredictGPModel(X_input, Model_test, 'MSE_Flag', 'On');
        Y_output = normrnd(Y_mean, sqrt(abs(Y_var)));
    
        Y_mean_val = mean(Y_output(:));
        Y_max_val = min(Y_output(:));

        Y_mean_values(j) = Y_mean_val; 
    
        emi_Y = EMI_Min(Y_mean_val, URL, Y_max_val);
        emi_Y_value(j) = emi_Y;
    
        deviation_Y = d_min(emi_Y, emi_target_Y);
    
        deviation_func = deviation_Y;
        
        d_value(j) = deviation_func;
    
    end
    [best_value, idx_min] = min(d_value);
    emi_for_best_d = emi_Y_value(idx_min);
    y_for_best_d = Y_mean_values(idx_min);


    

    best_d_history(end+1)   = best_value;  
    emi_best_d_history(end+1) = emi_for_best_d;
    y_best_d_history(end+1) = y_for_best_d;

    EI_vals = zeros(length(X_test),1);
    
    for i = 1:length(X_test)
    
        X_input_eo1 = normrnd(X_test(i), 10, [1000, 1]);
        X_input_eo = ones(1000, 1);
        X_input_eo(:, 1) = X_input_eo1;
        [Y_mean_eo, Y_var_eo] = PredictGPModel(X_input_eo, Model_test, 'MSE_Flag', 'On');
        Y_output_eo = normrnd(Y_mean_eo, sqrt(abs(Y_var_eo)));
        
        Y_mean_val_eo = mean(Y_output_eo(:));
        Y_max_val_eo = min(Y_output_eo(:));
        
        emi_Y = EMI_Min(Y_mean_val_eo, URL, Y_max_val_eo);
        
        deviation_Y_eo = d_min(emi_Y, emi_target_Y);
        
        deviation_func_eo = deviation_Y_eo;
        
        sigm_LY = std(Y_output_eo);
        
        imp = (deviation_func_eo - best_value);
        if sigm_LY == 0
            ei = 0;
        else
            Z = imp / sigm_LY;
            ei = imp * normcdf(Z) + sigm_LY * normpdf(Z);
        end
        
        EI_vals(i) =  ei;
    
    end


    [max_EI, idx_max] = max(EI_vals);
    x_new = X_test(idx_max);
    fprintf('Selected X_new = %.3f with EI = %.4f\n', x_new, max_EI);

    % Update training set
    X_train = [X_train; x_new];
    Y_train = [Y_train; f(x_new)];

    % Remove chosen point from test set
    X_test(idx_max) = [];

    % Log EI progression
    EI_progress(iteration) = max_EI;

    % ---- Plot 
    figure(1); clf;
    xx = linspace(lb, ub, 200)';
    plot(xx, f(xx), 'Color', [1 0.5 0], 'LineWidth', 2); hold on;
    scatter(X_train, Y_train, 50, [0.3 0.3 0.3], 'filled');
    xlabel('X'); ylabel('Y');
    title(sprintf('Adding candidate points on True Function in coupling BO with cDSP'));
    legend('True function', 'Additional Training points');

    
    figure(2); clf;
    plot(1:iteration, EI_progress(1:iteration), 'k-o','LineWidth',1.5);
    xlabel('Iteration'); ylabel('Max EI');
    title('Progression of Expected Improvement');
    grid on;
    
   
    % Increment iteration
    iteration = iteration + 1;
end


fprintf('\nBayesian Optimization finished after %d iterations.\n', iteration-1);
