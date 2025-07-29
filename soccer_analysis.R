head(RED_V_CMS2)

clean_data <- RED_V_CMS2[!is.na(RED_V_CMS2$TIME), ]

clean_data$minutes <- hour(clean_data$TIME) * 60 + minute(clean_data$TIME)

range(clean_data$minutes)

head(clean_data, 10)
nrow(clean_data)

unique(clean_data$ACTION)
table(clean_data$ACTION)

clean_data$event_type <- case_when(
  str_detect(clean_data$ACTION, "Shot|Header Shot") ~ "Shot",
  str_detect(clean_data$ACTION, "Corner kick") ~ "Corner Kick",
  str_detect(clean_data$ACTION, "substitution") ~ "Substitution",
  str_detect(clean_data$ACTION, "Yellow card") ~ "Yellow Card",
  str_detect(clean_data$ACTION, "goalie") ~ "Goalkeeper Setup",
  TRUE ~ "Other"  # This catches anything else
)
table(clean_data$event_type)

# Extract goals directly from the original dataset using text matching
goals_data <- clean_data[str_detect(clean_data$ACTION, "GOAL"), ]

# Get the exact goal times
goal_times <- goals_data$minutes
# Remove NA values from goal_times
goal_times_clean <- goal_times[!is.na(goal_times)]
print(paste("Clean goal times:", paste(goal_times_clean, collapse = ", ")))

# Find which time bins these goals fall into
goal_bins <- cut(goal_times_clean,
                 breaks = seq(0, 90, by = 5),
                 include.lowest = TRUE,
                 labels = paste0(seq(0, 85, by = 5), "-", seq(5, 90, by = 5)))

print("Goals occurred in these time bins:")
print(goal_bins)

# Compare with your most active periods
event_activity <- clean_data_filtered %>%
  group_by(time_bin) %>%
  summarise(total_events = n()) %>%
  arrange(desc(total_events))

print("Most active time periods (non-goal events):")
print(head(event_activity, 5))

# Check activity levels in goal time bins
for(i in 1:length(goal_times_clean)) {
  bin <- goal_bins[i]
  activity_in_bin <- event_activity[event_activity$time_bin == bin, "total_events"]
  events_count <- ifelse(nrow(activity_in_bin) > 0, activity_in_bin$total_events, 0)
  print(paste("Goal at minute", goal_times_clean[i], "occurred in bin", bin, "- Activity level:", events_count))
}


clean_data_filtered <- clean_data[!clean_data$event_type %in% c("Goalkeeper Setup", "Other", "Goal"), ]

clean_data$time_bin <- cut(clean_data$minutes,
                           breaks = seq(0, 90, by = 5),
                           include.lowest = TRUE,
                           labels = paste0(seq(0, 85, by = 5), "-", seq(5, 90, by = 5)))
table(clean_data$time_bin)

heat_matrix <- table(clean_data_filtered$event_type, clean_data_filtered$time_bin)
heat_matrix <- as.matrix(heat_matrix)
dim(heat_matrix)

heatmap_ggplot <- ggplot(heat_long, aes(x = Time_Bin, y = Event_Type, fill = Count)) +
  geom_tile(color = "white", size = 0.1) +
  geom_vline(xintercept = which(unique(heat_long$Time_Bin) %in% c("70-75", "75-80")),
             color = "red", linetype = "dashed", size = 1) +
  labs(title = "Event Distribution Heat Map",
       x = "Time Period", y = "Event Type") +
  scale_fill_gradient(low = "white", high = "red", name = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Show event types over time with goal overlay
library(reshape2)

# Reshape heat matrix for ggplot
heat_long <- melt(heat_matrix)
colnames(heat_long) <- c("Event_Type", "Time_Bin", "Count")

stacked_plot <- ggplot(heat_long, aes(x = Time_Bin, y = Count, fill = Event_Type)) +
  geom_bar(stat = "identity", position = "stack") +
  geom_vline(xintercept = which(levels(heat_long$Time_Bin) %in% c("70-75", "75-80")),
             color = "red", linetype = "dashed", size = 1) +
  labs(title = "Stacked Event Activity with Goal Time Markers",
       x = "Time Period", y = "Event Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

heatmap_ggplot / stacked_plot


