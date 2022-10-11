--AIM= Increase the number of enrolled users
/*
OBJECTIVES:-
1.Analyze various aspects of customer acquisition and see status of new users growth in company
2.Identify right metrics and frame proper questions for analysis
3.Understand team performace
4.Scope of improvemt
5.Understand target areas
6.Identify and exclude outliers in dataset
7.Dashboard and recommendations
*/

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Removing outliers from dataset
--1.Age = 211 and 116 from leads_basic_details dataset
select * from nxtwave_project.leads_basic_details where age in (211,116)
delete from nxtwave_project.leads_basic_details 
where age in (211,116);

--2. Watched Percentage - 233 and 510 from nxtwave_project.leads_demo_watched_details as watched percentage cannot be > 100
select * from nxtwave_project.leads_demo_watched_details where watched_percentage in (233,510)
delete from nxtwave_project.leads_demo_watched_details
where watched_percentage in (233,510);



-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------



--Details of educational background of majority of leads 
 with cte_education_background_leads as 
(select 
current_education, count(*) as Number_of_leads from 
nxtwave_project.leads_basic_details
group by current_education
 )

select x.current_education, x.Number_of_leads  from 
(select 
current_education,
Number_of_leads,
RANK() over (order by number_of_leads desc) as rnk
from cte_education_background_leads)x
where x.rnk <3;
--Leads_Percentage = Lead considered percentage (The most occuring current education form makes what percentage of total leads )
with cte_education_background_leads as 
(select 
current_education, count(*) as Number_of_leads from 
nxtwave_project.leads_basic_details
group by current_education
 )

select
265*100  -- 139+117
/
sum(cte_education_background_leads.Number_of_leads) as Leads_Percentage
from cte_education_background_leads ; --74%




--Details of parent occupation of leads
with cte_occupation_frequency as 
(select 
parent_occupation, count(*) as Number_of_Profession from 
nxtwave_project.leads_basic_details
group by parent_occupation)

select y.parent_occupation, y.Number_of_Profession   from 
(select 
parent_occupation,
Number_of_Profession,
RANK() over (order by Number_of_Profession desc) as rnk
from cte_occupation_frequency )y
where y.rnk <4;
--Sum of top three profession 
with cte_occupation_frequency as 
(select 
parent_occupation, count(*) as Number_of_Profession from 
nxtwave_project.leads_basic_details
group by parent_occupation)

select sum(y.Number_of_Profession) as sum_count from
(select 
parent_occupation,
Number_of_Profession,
RANK() over (order by Number_of_Profession desc) as rnk
from cte_occupation_frequency )y
where y.rnk<4;
--Profession percentage- what percentage of all listed professions do our selected 3 make up 
with cte_occupation_frequency as 
(select 
parent_occupation, count(*) as Number_of_Profession from 
nxtwave_project.leads_basic_details
group by parent_occupation)

select 
278*100
/
sum(cte_occupation_frequency.Number_of_Profession) as Leads_Percentage
from cte_occupation_frequency ; --77%


--THE RESULTS LEARNED FROM ABOVE ANALYSIS ARE :-
--1.Leads with education as Btech or Looking for Job make up 74% of leads. Thus customers with such education background should be focussed on for better results.
--2.Leads whose parents have profession of Govt Employee, Business and IT Employee make up 77% of leads. So, customers with such parent's profession should be focussed on for better results 
--Considering points 1 and 2 for further analysis:-
--Most occuring lead generating source is(email marketing):-

select 
z.lead_gen_source as max_occuring_source from 
(select lead_gen_source, current_city, gender, 
row_number() over (partition by lead_gen_source order by lead_gen_source) as rnk
from nxtwave_project.leads_basic_details
where 
nxtwave_project.leads_basic_details.parent_occupation in ('Business', 'IT Employee', 'Government Employee')
and  
nxtwave_project.leads_basic_details.current_education in ('B.Tech', 'Looking for Job')
)z
where z.rnk in (
select 
max(z.rnk) as max_occuring_source_total_count from 
--z.lead_gen_sourcer from 
(select lead_gen_source, current_city, gender, 
row_number() over (partition by lead_gen_source order by lead_gen_source) as rnk
from nxtwave_project.leads_basic_details
where 
nxtwave_project.leads_basic_details.parent_occupation in ('Business', 'IT Employee', 'Government Employee')
and  
nxtwave_project.leads_basic_details.current_education in ('B.Tech', 'Looking for Job')
)z
)



--Most occuring lead generating city is(FOUND:Visakhapatnam):-
select 
z.current_city as max_occuring_source from 
(select lead_gen_source, current_city, gender, 
row_number() over (partition by current_city order by current_city) as rnk
from nxtwave_project.leads_basic_details
where 
nxtwave_project.leads_basic_details.parent_occupation in ('Business', 'IT Employee', 'Government Employee')
and  
nxtwave_project.leads_basic_details.current_education in ('B.Tech', 'Looking for Job')
)z
where z.rnk in (
select 
max(z.rnk) as max_occuring_source_total_count from 
--z.lead_gen_sourcer from 
(select lead_gen_source, current_city, gender, 
row_number() over (partition by current_city order by current_city) as rnk
from nxtwave_project.leads_basic_details
where 
nxtwave_project.leads_basic_details.parent_occupation in ('Business', 'IT Employee', 'Government Employee')
and  
nxtwave_project.leads_basic_details.current_education in ('B.Tech', 'Looking for Job')
)z
)



-------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Langauage distribution of leads demo watched 
select language, count(*) as language_count
from nxtwave_project.leads_demo_watched_details
group by language
order by language

--Demo watched percentage count 
select watched_percentage, count (*) as percentage_count
from nxtwave_project.leads_demo_watched_details
group by watched_percentage
order by percentage_count desc

--Success of demo videos = those languages where its watched percent is > 65
/*select
sum(e.success_count_per_language) as total_sum
from  (select language, count(*) as success_count_per_language
--percent_rank() over (order by language )
from nxtwave_project.leads_demo_watched_details
where watched_percentage > 65
group by language
)e*/
select language, count(*) as success_count_per_language
from nxtwave_project.leads_demo_watched_details
where watched_percentage > 65
group by language
order by success_count_per_language desc
--Thus, most viewtime on demo video can be got when they are seen in english by the customer 

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Out of all calls made, how many potential customers are being missed out 
select count(t.call_status) as missed_potential_customer
from 
(select call_reason, lead_Stage, call_done_date, call_Status
from nxtwave_project.leads_interaction_details
where call_status in ('unsuccessful') --alls that the customer did not pick up , and that customer was labelled in consideration and awareness stage 
and lead_stage not in ('Conversion','lead')
)t
--Total count leads reached by call
select count(jnr_sm_id) as total_leads_reached_count
from nxtwave_project.leads_interaction_details

--Potential percentage of customers missed 
select cast (
(select 
(select count(t.call_status)*100
from (select call_reason, lead_Stage, call_done_date, call_Status
from nxtwave_project.leads_interaction_details
where call_status in ('unsuccessful') --alls that the customer did not pick up , and that customer was labelled in consideration and awareness stage 
and lead_stage not in ('Conversion','lead')
)t)
/
(select count(jnr_sm_id)
from nxtwave_project.leads_interaction_details)
as missed_percentage) as float) as missed_percentage
--value is 2%

--Total customers who didnot attend demo but call was successful  = all of them are lead (seen from dataset)
select count(*) as lead_count_demo_not_attended
from nxtwave_project.leads_interaction_details
where call_status in ('Successful')
and
call_reason in ('demo_not_attended')

--Total customers labelled as lead
select count(*) as count_lead
from nxtwave_project.leads_interaction_details
where lead_Stage in ('lead')
and call_status in ('Successful')

--Thus people who lead and attended demo but are still not labelled as consideration 
select(
(select count(*)
from nxtwave_project.leads_interaction_details
where lead_Stage in ('lead'))
-
(select count(*)
from nxtwave_project.leads_interaction_details
where call_status in ('Successful')
and
call_reason in ('demo_not_attended')))
--930. Thus focus needs to be put on customers who attend the demo but still remain lead and not shifted to other lead stage

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Information on distribution for customer's reason for not being interested in demo 
select reasons_for_not_interested_in_demo, count(*) as reason_not_interested_count
from nxtwave_project.leads_reasons_for_no_interest
group by reasons_for_not_interested_in_demo
order by reason_not_interested_count desc

--Information on distribution for customer lead's reason for not converting 
select reasons_for_not_interested_to_convert, count(*) as leads_reason_no_interested_count
from nxtwave_project.leads_reasons_for_no_interest
group by reasons_for_not_interested_to_convert
order by leads_reason_no_interested_count desc

--Information on distribution for customer's reason for not finding our product as their solution  
select reasons_for_not_interested_to_consider, count(*) as reason_not_interested_to_consider_count
from nxtwave_project.leads_reasons_for_no_interest
group by reasons_for_not_interested_to_consider
order by reason_not_interested_to_consider_count desc

--From the distributions here, it is evident that lead wanting "Offline classes" or lead being in a situation that they "Cannot afford" is the predoinant reason for 
--the leads not being able to be converted(Both these reason occur in top 3 reasons in each of the above result sets) - Thus this area needs to be worked on.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Number of leads assigned per cycle
select cycle, count(*) as assigned_count
from nxtwave_project.sales_managers_assigned_leads_details
group by cycle 
order by assigned_count desc



