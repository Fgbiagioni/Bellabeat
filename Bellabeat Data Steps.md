# Case Study 2: How Can a Wellness Technology Company Play It Smart?
## By: Fabrizio Biagioni

### Introduction
For this project, I will take the role of a junior data analyst working on the marketing analyst team at Bellabeat, a high-tech manufacturer of health-focused products for women. This is a case presented by Google Career Certificates for the Data Analytics specialization. 
According to the case, Bellabeat is a successful small company, but they have the potential to become a larger player in the global smart device market. Urška Sršen, cofounder and Chief Creative Officer of Bellabeat, believes that analyzing smart device fitness data could help unlock new growth opportunities for the company. I have been asked to focus on one of Bellabeat’s products and analyze smart device data to gain insight into how consumers are using their smart devices. 
Sršen knows that an analysis of Bellabeat’s available consumer data would reveal more opportunities for growth. She has asked the marketing analytics team to focus on a Bellabeat product and analyze smart device usage data in order to gain insight into how people are already using their smart devices. Then, using this information, she would like high-level recommendations for how these trends can inform Bellabeat marketing strategy.

### Ask 
Sršen is asking to analyze smart device usage data in order to gain insight into how consumers use non-Bellabeat smart devices. For this scenario, I will be taking into consideration the Leaf Tracker, as it is one of the most popular products of Bellabeat, according to the customer’s reviews on their website (For reference: https://bellabeat.com/product/leaf-urban/). Also, this tracker summarizes all Bellabeat’s ideology of healthiness and efficiency for Woman’s lifes.
According to the research of Mordor Intelligence, “The global smart tracker market (henceforth referred to as the market studied) was valued at USD 421.02 million in 2020, and it is expected to reach USD 911.58 million by 2027, registering a CAGR of 12.8% during the period of 2020-2027”. That is why we can take advantage of this trend to promote our most popular product, the Ivy Health Tracker and increase our sales and revenue. As many of Bellabeat’s products are trackers or accessories for trackers, we can confirm that this global trend also includes the majority of Bellabeat’s customers and we can consider this for our marketing strategy.
The problem: Bellabeat team is looking for opportunities to grow and understand more of its consumer’s preferences.

Objective: Identify market data to gain insight into the consumer’s activities and preferences, in order to give effective recommendations for the company.
Business task:

Key stakeholders: 
* Urška Sršen: Bellabeat’s cofounder and Chief Creative Officer
* Sando Mur: Mathematician and Bellabeat’s cofounder; key member of the Bellabeat executive team
* Bellabeat marketing analytics team: A team of data analysts responsible for collecting, analyzing, and reporting data that helps guide Bellabeat’s marketing strategy. 

Data: The data for this analysis will be the FitBit Fitness Tracker Data (CC0: Public Domain, dataset made available through Mobius): This Kaggle data set contains personal fitness tracker from thirty fitbit users. Thirty eligible Fitbit users consented to the submission of personal tracker data, including minute-level output for physical activity, heart rate, and sleep monitoring. It includes information about daily activity, steps, and heart rate that can be used to explore users’ habits.

### Prepare
The FitBit Fitness Tracker Data is stored in Kaggle and I will begin to analyze it in Excel to have a first approach at the information. The data is organized in 18 CSV files in a long format, with one being the merged version of the rest.

Some problems with the data are that it only contains information for 30 users, so it might be biased. Also, it only has information for the activity of the users, but apart from their weight, the data does not contain more information of their description, such as their gender, location, age, etc.

Finally, the data doesn’t ROCCC (Reliability, Original, Comprehensive, Current, Cited) because, even if it is cited and has a license, it is very old (2016), the sample size is very small, and it contains a lot of missing values. The latter has been confirmed by analyzing the data in excel.

For the purpose of this analysis, I will still be using this data, assuming that the data is “good” and ROCCS, because it has valuable information for the market of trackers and can help us understand the demand. 

### Process and Analysis
For this steps, I will be using Microsoft SQL Server Management. Please refer to the attaches SQL file to visualize my code and comments.
