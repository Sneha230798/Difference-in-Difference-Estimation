
* FGLS FOR CPS DATA USING HANSEN

clear

* Set the number of simulations and other parameters
local num_simulations 20
local true_beta1_value 0
local alpha 0.05

* Initialize lists to store simulation results
local bias_values ""
local squared_error_values ""
local standard_error_values ""
local beta1_estimates ""
local reject_count 0

forval sim = 1/`num_simulations' {

	use "C:\Users\Biswajit Palit\Downloads\cps_data_raw.dta"
	
	* Create the outcome variable
	gen outcome = INCWAGE
	gen log_wage = log(INCWAGE)
	reg log_wage AGE High_School Master_s_Degree 
	predict Residuals, residuals
	
	collapse (mean) Residuals, by(STATEFIP YEAR)
	
	egen random_number = mean(runiform()), by(STATEFIP)
	sort random_number STATEFIP YEAR

    gen treatment_states = 0
    replace treatment_states = 1 if _n <= _N / 2

    gen treatment_year = 0
	bysort STATEFIP (treatment_states): replace treatment_year = int((1995 - 1985 + 1) * runiform() + 1985) if treatment_states[1] == 1
	sort STATEFIP YEAR
	bysort STATEFIP: replace treatment_year = treatment_year[_N / 2]
	
	gen treatment = 0
	replace treatment = (YEAR >= treatment_year) if treatment_year != 0

	sort STATEFIP YEAR
	
    xtset STATEFIP YEAR
	
    hansen Residuals treatment, group(STATEFIP) time(YEAR) 

    * Extract coefficient and standard error for treatment
    local treatment_coef = _b[treatment]
    local treatment_se = _se[treatment]

    * Store simulation results
    local bias = `treatment_coef' - `true_beta1_value'
    local squared_error = (`treatment_coef' - `true_beta1_value')^2
    local standard_error = `treatment_se'

    * Append results to lists
    local bias_values "`bias_values' `bias'"
    local squared_error_values "`squared_error_values' `squared_error'"
    local standard_error_values "`standard_error_values' `standard_error'"
    local beta1_estimates "`beta1_estimates' `treatment_coef'"

    * Test hypothesis for treatment and get p-value
    local t_stat = `treatment_coef' / `treatment_se'
    local p_value = 2 * (1 - normal(abs(`t_stat')))


    if `p_value' < `alpha' {
        local reject_count = `reject_count' + 1
    }


    * Clear generated variables for next simulation
    drop treatment_states treatment_year treatment Residuals YEAR STATEFIP random_number
    * Include additional commands to drop variables generated by hansen if necessary
}

* Display simulation results
di "Simulation Results:"
di "Reject Count: " `reject_count'
di "Bias Values: " `bias_values'
di "Squared Error Values: " `squared_error_values'
di "Standard Error Values: " `standard_error_values'
di "Beta1 Estimates: " `beta1_estimates'































* FGLS POWER FOR CPS DATA USING HANSEN

clear



* Set the number of simulations and other parameters
local num_simulations 50
local true_beta1_value 0.02
local alpha 0.05

* Initialize lists to store simulation results
local bias_values ""
local squared_error_values ""
local standard_error_values ""
local beta1_estimates ""
local reject_count 0

forval sim = 1/`num_simulations' {

	use "C:\Users\Biswajit Palit\Downloads\cps_data_raw.dta"
	
	egen random_number = mean(runiform()), by(STATEFIP)
	sort random_number STATEFIP YEAR

    gen treatment_states = 0
    replace treatment_states = 1 if _n <= _N / 2

    gen treatment_year = 0
	bysort STATEFIP (treatment_states): replace treatment_year = int((1995 - 1985 + 1) * runiform() + 1985) if treatment_states[1] == 1
	sort STATEFIP YEAR
	bysort STATEFIP: replace treatment_year = treatment_year[_N / 2]
	
	gen treatment = 0
	replace treatment = (YEAR >= treatment_year) if treatment_year != 0
	
	* Create the outcome variable
	gen outcome = INCWAGE
	*Update the outcome variable based on the treatment condition
	replace outcome = outcome * 1.02 if treatment == 1
	gen log_wage = log(outcome)
	reg log_wage AGE High_School Master_s_Degree 
	predict Residuals, residuals
	
	collapse (mean) Residuals treatment_states treatment_year treatment, by(STATEFIP YEAR)

	sort STATEFIP YEAR
	
    xtset STATEFIP YEAR
	
    hansen Residuals treatment, group(STATEFIP) time(YEAR) 

    * Extract coefficient and standard error for treatment
    local treatment_coef = _b[treatment]
    local treatment_se = _se[treatment]

    * Store simulation results
    local bias = `treatment_coef' - `true_beta1_value'
    local squared_error = (`treatment_coef' - `true_beta1_value')^2
    local standard_error = `treatment_se'

    * Append results to lists
    local bias_values "`bias_values' `bias'"
    local squared_error_values "`squared_error_values' `squared_error'"
    local standard_error_values "`standard_error_values' `standard_error'"
    local beta1_estimates "`beta1_estimates' `treatment_coef'"

    * Test hypothesis for treatment and get p-value
    local t_stat = `treatment_coef' / `treatment_se'
    local p_value = 2 * (1 - normal(abs(`t_stat')))


    if `p_value' < `alpha' {
        local reject_count = `reject_count' + 1
    }


    * Clear generated variables for next simulation
    drop treatment_states treatment_year treatment Residuals YEAR STATEFIP 
    * Include additional commands to drop variables generated by hansen if necessary
}

* Display simulation results
di "Simulation Results:"
di "Reject Count: " `reject_count'
di "Bias Values: " `bias_values'
di "Squared Error Values: " `squared_error_values'
di "Standard Error Values: " `standard_error_values'
di "Beta1 Estimates: " `beta1_estimates'










