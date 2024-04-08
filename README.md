# Actuarial Theory and Practice A @ UNSW 

_"Tell me and I forget. Teach me and I remember. Involve me and I learn" - Benjamin Franklin_

---

## <font color=#c5f015>Group 3</font>

>Group member: Joshua Ashokan, Yao Li, Zhiyue Pan, Boyuan Bai, Yawei Wang

>Here is the website of our work for SOA 2024 assignment



## <span style="color:#c5f015">Website Guide</span>
---

- **Report**: The `ACTL5100 Group 3 Case Report.pdf` file contains the main concept proposed by our group, along with all associated risks and analyses.

- **Code**: The `life_insurance.py` file includes the main technical aspects utilized in our project.

- **Mortality Decrement Calculation**: Refer to the `Decrement Summary.xlsx` notebook for details on how the mortality decrement was calculated based on our assumptions.

- **Datasets**: All other `.csv` and `.zip` files are used as input datasets for our analysis.

## Executive Summary

> ActuarialLife Innovations has proposed a health incentive program to be bundled with SuperLife’s insurance products, aiming to reduce policyholder mortality, encourage healthy behaviours, and enhance economic value. Implementing the program 20 years ago would have resulted in mortality savings of Ć0.58b. Projections indicate potential mortality savings of Ć125.43m and profits of Ć75.95m over 20 years. Risks, ethics, and data limitations were considered throughout program development and modelling, and mitigation strategies were recommended.

## Overview

> The main objectives for the program are to incentivise healthy behaviours, decreased expected mortality, increase life insurance sales, improve product marketability and competitiveness, and to add economic value to SuperLife.
>
> Metrics used to assess program performance are policyholder participation, policies sold, lapse rate monitoring, mortality rate monitoring, market share, customer satisfaction, profitability, and claim frequency and severity.

## Program Design

### Incentives:
 
- Fitness Tracking Incentives: Policyholders are incentivised with monetary rewards for meeting predetermined physical activity levels.

- Discounted Gym Memberships: Policyholders will have access to gym facilities at discounted rates to encourage increased physical activity levels.

The selection of incentives was guided by the main causes of death among existing SuperLife policyholders as well as the complimentary nature of both interventions.

### Evaluation timeframes:

- Short-term evaluation has been selected at the 5-year mark, as it allows mortality trends to become evident, and a better understanding of life insurance products. Additionally, more frequent monitoring is recommended to allow for immediate program adjustments.

- Long-term valuation has been selected at the 20-year mark, primarily due to the long-term nature of life insurance products. This time frame will also allow for the assessment of product performance in various economic cycles or major events.

## Pricing/Costs

### Mortality Savings

The mortality savings from the proposed program were assessed over a 20-year period. This involved comparing the total cost of claims with and without the program over a 20-year timeframe.)

|                        | Total Claim Costs (Č) Without Program   |  Total Claim Costs (Č) With Program      |     Mortality Savings (Č)             |   Mortality Savings (%)  |Number of Policies |
|------------------------|-------------------|-------------------|-------------------|-------------------|-------------------|
| 20-year Term           | 4.21b             | 3.88b             | 0.33b             | 7.7%              | 311,595           |
| Whole Life             | 27.38bm           | 27.13b            | 0.25b             | 0.9%              | 117,566           |
| Total                  | 31.60b            | 31.02b            | 0.58b             | 1.8%              | 429,161           |

The program's performance was projected for both 5-year and 20-year periods to evaluate its financial performance. This was done to ensure that the benefits exceed the costs and that the program contributed more to SuperLife's economic value than without it.


| 5-year Timeframe| Total Claim Costs (Č) Without Program| Total Claim Costs (Č) With Program |   Mortality Savings (Č)  | Expenses | Profit |
|-----------------|------------------------|----------------------|------------------------|------|------|
| 20-year Term    | 4.86m                  | 4.58m                | 0.28m                  | 6.59m| (6.31m) |
| Whole Life      | 19.89m                 | 18.55m               | 1.34m                  | 6.71m| (5.37m) |
| Total           | 24.75m                 | 23.13m               | 1.62m                  | 13.30m| (11.68m) |

|         20-year Timeframe          |Total Claim Costs (Č) Without Program  | Total Claim Costs (Č) With Program         | Mortality Savings (Č) | Expenses | Profit |
|-------------------|------------------------|-------------------------|------------------------|----------|--------|
| 20-year Term      | 1,069.81m              | 994.92m                 | 74.89m                 | 24.28m   | 50.61m |
| Whole Life        | 664.86m                | 614.33m                 | 50.54m                 | 25.20m   | 25.34m |
| Total             | 1,734.68m              | 1,609.25m               | 125.43m                | 49.48m   | 75.95m |

### Proposed Pricing Changes

To increase SuperLife’s long-term investment income, policyholders, specifically younger ones, should be incentivised to switch from the 20-year term to whole life insurance. A discount to whole life premiums is suggested to encourage this transition as well as improve SuperLife’s competitiveness in Lumaria’s life insurance market.

## Assumptions

- In-force policyholder data used for projections spanning 2024-2046 is assumed to mirror the provided data for the period of 2001-2023.

- The inflation rate used for projections was the average of the previous two years.

- The discount rate was the average of the 1-year discount rate from the last 10 years.

- Death benefits are paid at the end of the calendar year, and incentive expenses are paid at the start of each year.

- Gym membership expenses and fitness tracking rewards are assumed to cost Ć104 and Ć106 respectively.

- Program participation rates and reward probabilities are based on international case studies on activity levels across various age groups.

- Baseline mortality improvement was selected at 16% based on case studies on the effects of physical activity on mortality.

- Mortality reduction for each group is determined by analysing which causes of mortality risk are affected by physical activity and the proportion of the age group affected by those causes.

## <span style="color:blue">Risk and Risk Mitigation Considerations</span>

| # | Risk Category    | Risk | Severity, Likelihood | Description/Mitigation |
|---|------------------|------|----------------------|------------------------|
| 1 | Financial Risk   | Inflation Risk | (4,2) | Inflationary pressures may affect program participation rates, expenses, incentives, and premiums. This may lead to a higher lapse rate and reduced profitability. **Mitigation:** Sensitivity analysis for higher inflation, expenses, lapse rates with contingency strategies prepared. |
| 2 | Strategic Risk   | Gym Under-utilisation Risk | (2,2) | Policyholders sign up for discounted gym facilities without using them, resulting in minimal impact on mortality rates or savings. **Mitigation:** Monitor attendance rates and exercise frequency. Consider adjusting discounts based on participation (i.e., a tiered discount system). |
| 3 | Under-writing Risk | Selection Risk | (2,3) | Policyholders who already engage in a high level of physical activity join the program for the monetary benefits, and do not actually decrease their mortality risk. **Mitigation:** Define goals for participants based on their recent fitness levels to properly incentivise activity levels. |
| 4 | Operational Risk | Moral Risk | (2,3) | The potential for policyholders to submit inaccurate or dishonest fitness data to receive monetary rewards. **Mitigation:** Implement user authentication methods when uploading activities to SuperLife to verify data submissions. |
| 5 | Operational Risk | Injury Risk | (3,2) | Encouraging physical activity may lead policyholders to engage in unfamiliar exercises, increasing the risk of injury. **Mitigation:** Provide injury prevention information upon enrolment to policyholders. |
| 6 | Strategic Risk | Reputational Risk | (4,1) | Policyholders provide sensitive, personal data and may misunderstand how it is used by SuperLife, leading to mistrust and a damaged reputation for the company. **Mitigation:** Communicate clearly to policyholders the collection, storage, and use of their data, obtaining consent upon enrolment on SuperLife’s data processes. |
| 7 | Event Risk | Crises/ Pandemic Risk | (5,1) | A global event such as a financial crisis or pandemic occurs. **Mitigation:** Use experience from previous events (e.g., GFC, COVID-19) to develop contingency plans. This information should be provided to policyholders in the program’s PDS. |

## Ethical 
| Consideration | Mitigation |
|---------------|------------|
| The program emphasises physical activity which may pose challenges for policyholders with disabilities, which may result in the program being perceived as unfair and exclusive. | Collect information about policyholder abilities upon enrolment and tailor activity goals accordingly to accommodate those of all ability levels. |
| Policyholders may feel excluded if they lack access to or are unfamiliar with fitness tracking devices, potentially leading to lower participation rates. | Offer alternative methods for fitness tracking, such as manual logging with the supervision of a qualified instructor. |
| Variables such as age, gender, or race used to calculate program metrics may indirectly lead to discrimination or bias, possibly resulting in dissatisfied policyholders and reputation damage. | Conduct research on ethical variable usage in accordance with Lumarian regulations. Remove variables and their proxies to prevent inadvertent discrimination. |
| Certain demographics may feel excluded if the marketing campaigns are not tailored to reach them, which may lead to lower participation rates. | Conduct market research on advertising styles and channels to ensure that campaigns are targeted equally at all policyholder demographics. |

## Sensitivity Analysis

Various scenarios were tested to ensure robustness of the proposed program against a range of assumptions (Note: The following % changes are multiplicative not additive):

- Scenario 1: Change in mortality rates (+/- 10% to mortality rates for all age groups)

- Scenario 2: Change in lapse rates (+/- 10% to lapse rate for 20-year term insurance)

- Scenario 3: Change in interest rates (+/- 10% to interest rates)

- Scenario 4: Change in inflation rates (+/- 10% to inflation rates)

In the above scenarios, the program was financially viable and showed strong financial performance.

## Data and Data Limitations

Data from SuperLife’s task force was used during program design, assumption setting, modelling, program evaluation. No external sources of data were used.

The following data limitations were present:

- Insufficient Historical Data: As life insurance products are long-term in nature, additional historical data would have been useful to observe mortality trends.

- Mortality Data Depth: More granular data regarding cause of death would have allowed for better understanding of the causes of death for policyholders. It also would have allowed for consideration of interventions targeting specific causes of death.

- Data Reliability: There are no lapses for whole life policies in the dataset, and the observed lapse rate for term insurance policies was 1%. This is much lower than industry estimates for both products.

- Physical Activity Data: The program revolves around increasing physical activity to improve policyholder mortality, however, data on existing policyholder activity levels is not available.

- Data Availability: SuperLife’s reserve rate, capital, and commission expenses were not available.

## Conclusion

The proposed health incentive program offers SuperLife the chance to improve their insurance offerings, promote healthier lifestyles, and reduce policyholder mortality. To ensure success in the implementation of this program, SuperLife must monitor performance metrics, employ risk mitigation techniques, and address any potential ethical considerations. SuperLife should also consider offering a discount to policyholders signing up to whole life insurance, as it increases economic value, and provides more complete coverage for policyholders.

Please send us email if there is any confusion in understanding the report content or running the codes.
![](Actuarial.gif)
