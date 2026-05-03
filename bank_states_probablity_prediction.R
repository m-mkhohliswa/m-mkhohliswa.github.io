setwd("C:\\Users\\musam\\Portfolio_Analysis\\scripts\\r_scripts")
library(quantmod)
library(pander)
library(xts)
library(DBI)
library(RMySQL)
library(data.table)
library(tidyr)
library(FSA)
library(car)
library(rstatix)
library(ggplot2)
library(MASS)
library(e1071)
library(markovchain)
connect = dbConnect(RMySQL::MySQL(),
                    host     = "localhost",
                    dbname   = "churn_states",
                    user     = "root",
                    password = "Mkhohliswa@1407",
                    port     = 3306
)

churn_raw = dbReadTable(connect, "churn_raw")
churn_states = dbReadTable(connect,"churn_states")
churn_transition_matrix = dbReadTable(connect,"transition_matrix")
#write.csv(churn_transition_matrix.csv,"C:\\Users\\musam\\Portfolio_Analysis\\data_files\\churn_transition_matrix.csv")
#write.csv(churn_states.csv,"C:\\Users\\musam\\Portfolio_Analysis\\data_files\\churn_states.csv")
#write.csv(churn_raw.csv,"C:\\Users\\musam\\Portfolio_Analysis\\data_files\\churn_raw.csv")
transMatrix_churn = read.csv("C:\\Users\\musam\\Portfolio_Analysis\\data_files\\transition_matrix_result.csv", header=T)
colnames(transMatrix_churn)
state_names = c("Active_Retained", "Inactive_Retained", "Active_Churned","Inactive_Churned")
transMatrix_churn = as.matrix(transMatrix_churn)
transMatrix_churn = transMatrix_churn[, -1]
dimnames(transMatrix_churn) = list(state_names, state_names)

class(transMatrix_churn) = "numeric"
transMatrix_bank = new("markovchain", states = state_names, transitionMatrix = transMatrix_churn)

Initial_Dist = c(0.442, 0.355, 0.073, 0.13)

Active_RetainedP = c()
Inactive_RetainedP = c()
Active_ChurnedP = c()
Inactive_ChurnedP = c()

# 1. Initialize an empty data frame to store results
steps = data.frame()

# 2. Run the loop
for(k in 1:10){
  # Calculate probabilities for step k
  nsteps = Initial_Dist * (transMatrix_bank^k)
  
  # Create a temporary data frame for this iteration
  current_step <- data.frame(
    Iter = rep(k, 4),
    Group = state_names,
    Value = as.numeric(nsteps)
  )
  
  # Append to the main table
  steps = rbind(steps, current_step)
}
#write.csv(steps, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\steps.csv")

# Convert matrix to a long format for Power BI
transition_long <- as.data.frame(transMatrix_churn) %>%
  mutate(From = rownames(.)) %>%
  pivot_longer(-From, names_to = "To", values_to = "Probability")

write.csv(transition_long, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\transition_long.csv")
# 3. Plotting
ggplot(steps, aes(x = Iter, y = Value, color = Group)) +
  geom_line(size = 1) + 
  geom_point() +
  labs(
    title = "10 Step Chain Probability Prediction",
    x = "Chain Steps",
    y = "Probability"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
# -------------------------------
# MARKOV CHAIN INTERPRETATION
# -------------------------------

# The Markov chain projection over 10 steps reveals a strong long-term drift
# toward churn-dominated states, particularly "Inactive_Churned".

# 1. Inactive_Churned:
# - Probability increases steadily across all steps.
# - Becomes the most dominant state in the long run (~46%).
# - Interpretation: Customers tend to eventually become inactive and churned,
#   indicating weak recovery or reactivation mechanisms.

# 2. Active_Churned:
# - Shows a consistent upward trend over time.
# - Suggests that many customers transition from active engagement directly
#   into churn before becoming inactive.
# - Indicates early-stage churn risk even among active users.

# 3. Active_Retained:
# - Starts as the most probable state but declines significantly over time.
# - Drops from ~38% to below 10%.
# - Interpretation: Customer retention is not sustainable in the long run,
#   and active users are gradually lost to churn states.

# 4. Inactive_Retained:
# - Rapidly decreases to near zero probability.
# - This is a highly unstable/transient state.
# - Interpretation: Inactive customers are unlikely to remain retained;
#   they tend to transition quickly into churned states.

# Overall Insight:
# - The system converges toward churn-heavy states.
# - Retention states (both active and inactive) are not stable over time.
# - This suggests:
#     * High transition probabilities into churn states
#     * Low probabilities of recovery (reactivation or retention)
# - Business implication: Intervention strategies are needed to:
#     * Improve retention of active customers
#     * Increase reactivation rates of inactive customers
#     * Reduce transitions into churn states

# -------------------------------------------
# RISK SEGMENTATION USING MARKOV CHAIN STATES
# -------------------------------------------

# The Markov chain states can be directly mapped to churn risk profiles:

# 1. Conservative Risk (Low Risk):
# - State: Active_Retained
# - Customers are engaged and retained
# - Represents the most stable and valuable segment
# - However, results show this segment declines over time,
#   indicating poor long-term retention

# 2. Moderate Risk:
# - State: Inactive_Retained
# - Customers are disengaged but not yet churned
# - This state is highly transient and decays quickly
# - Interpretation: There is a short intervention window before churn

# 3. High Risk:
# - State: Active_Churned
# - Customers are still active but already exhibit churn behavior
# - This segment grows over time, suggesting increasing early churn signals
# - Represents a critical segment for targeted retention strategies

# 4. Aggressive Risk (Churned Customers):
# - State: Inactive_Churned
# - Customers are both inactive and churned
# - This becomes the dominant long-run state
# - Indicates that the system converges toward customer loss

# -------------------------------------------
# DYNAMIC RISK MIGRATION INSIGHT
# -------------------------------------------

# The Markov process shows a one-directional flow:
# Conservative → Moderate → High → Aggressive

# There is minimal evidence of reverse transitions (recovery),
# suggesting:
# - Low reactivation probabilities
# - High persistence in churn states

# -------------------------------------------
# BUSINESS IMPLICATIONS
# -------------------------------------------

# 1. Retention Strategy:
# - Focus on protecting "Active_Retained" customers early
# - Prevent transition into "Inactive_Retained"

# 2. Intervention Strategy:
# - Target "Inactive_Retained" customers quickly
# - This segment has a high likelihood of escalating to churn

# 3. Early Warning System:
# - Monitor "Active_Churned" customers
# - Use predictive signals to intervene before full churn

# 4. Recovery Strategy:
# - Improve transition probabilities from "Inactive_Churned"
#   back to retained states (currently very low)

# Overall Conclusion:
# - The system behaves like a churn funnel with increasing risk over time
# - Without intervention, customers systematically migrate toward
#   high-risk and churned states
