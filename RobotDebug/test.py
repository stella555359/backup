from datetime import datetime, timedelta

def split_intervals(intervals, delta_minutes=30):
    result = []
    for start_str, end_str in intervals:
        start = datetime.strptime(start_str, "%Y-%m-%d %H:%M:%S")
        end = datetime.strptime(end_str, "%Y-%m-%d %H:%M:%S")
        current = start
        while current < end:
            next_time = min(current + timedelta(minutes=delta_minutes), end)
            # Only add the interval if its duration is at least delta_minutes
            if (next_time - current).total_seconds() >= delta_minutes * 60:
                result.append(
                    [
                        current.strftime("%Y-%m-%d %H:%M:%S"),
                        next_time.strftime("%Y-%m-%d %H:%M:%S"),
                    ]
                )
            current = next_time
    return result

# Test input
report_timestamps_list = [['2026-03-18 15:48:41', '2026-03-18 21:48:46']]
# Run the function and print the output
output = split_intervals(report_timestamps_list, delta_minutes=30)
print(output)