# ============================================================================
# Question 4: TLG - Adverse Event Reporting (Script 2)
# ============================================================================
#
# Visualizations using {ggplot2}
#
# Author: Ortensia Vito
# ============================================================================

# Load required packages
library(dplyr)
library(pharmaverseadam)
library(ggplot2)

setwd("~/Desktop/GitHub/technical-interview-april-2026/question_4_tlg")

# Import the data.frame
adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

# Plot the AE severity distribution by treatment

ae_sev <- adae %>%
  dplyr::select(ACTARM, AESEV) %>%
  group_by(ACTARM, AESEV) %>%
  tally() %>%
  ggplot(aes(fill = AESEV, y = n, x = ACTARM)) + 
  geom_bar(position = "stack", stat = "identity") +
  labs(title = "AE severity distribution by treatment", x = "Treatment Arm", y = "Count of AEs") +
  scale_fill_discrete(name = "Severity/Intensity") +
  theme(axis.title = element_text(face = "bold"),
        legend.title = element_text(face = "bold"),
        plot.title = element_text(face = "bold")) 

ggsave("ae_severity_distribution_by_treatment.png")

# Plot the top 10 most frequent AEs (with 95% CI for incidence rates). 

ae_top_aes <- adae %>%
  dplyr::select(USUBJID, AETERM) %>%
  group_by(AETERM) %>%
  summarise(n_events = n_distinct(USUBJID), .groups = "drop") %>%
  # get total number of patients from adsl
  mutate(N = n_distinct(adae$USUBJID)) %>%
  # calcualte percentages and CIs
  mutate(
    proportion = (n_events/N) *100,
    ci_lower = qbinom(0.025, N, n_events/N) / N * 100,
    ci_upper = qbinom(0.975, N, n_events/N) / N * 100
  ) %>%
  # select the top 10 AEs
  arrange(desc(proportion)) %>%
  slice_head(n = 10) %>%
  # reorder the factors for plotting
  mutate(AETERM = factor(AETERM, levels = rev(AETERM))) %>%
  ggplot(aes(x = proportion, y = AETERM)) +
  geom_point(size = 3) +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.3) +
  labs(title = "Top 10 Most Frequent Adverse Events", subtitle = "n = 225 subjects; 95% CIs", 
       x = "Percentage of Patients (%)", y = "") +
  theme(axis.title = element_text(face = "bold"),
        plot.title = element_text(face = "bold"))

ggsave("top_10_aes.png")
  
