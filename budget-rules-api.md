Recurring Budget Rules API
===========================

The recurring budget rules API allows users to create budget rules.
Users can get, set, update, and delete these rules.

## Get Recurring Rules `http://<kubecost-address>/model/getRecurringBudgetRules`

This endpoint lists all the recurring budget rules 

### Example Response
```
[
    {
        "name":"weekly-test",
        "id":"4cf575d0-2d3f-4d86-bc1f-bd4e937da320",
        "filter":"",
        "kind":"soft",
        "interval":"weekly",
        "intervalDay":1,
        "amount":50
    },
    {
        "name":"monthly-test",
        "id":"783d69e7-97ce-4385-8cbe-fffdc8168bb9",
        "filter":"",
        "kind":"soft",
        "interval":"monthly",
        "intervalDay":21,
        "amount":50
    }
]
```

## Set Recurring Rules `http://<kubecost-address>/model/setRecurringBudgetRules`

This endpoint creates a recurring budget rule or updates a recurring budget rule given the id of the rule

### Create Recurring Rule

#### Expected Payload
| Name | Type | Required? | Description |
|------|------|-----------|-------------|
| name | string | yes | The name of the budget rule |
| filter | string | no | The filter (either namespace or cluster) for the rule. Defaults to "". |
| kind | string | no | The type of budget. Takes either "hard" or "soft". Defaults to "soft" |
| interval | string | yes | The interval with which the budget is reset. Takes either "weekly" or "monthly" |
| intervalDay | int | no | The day the budget will reset. For weekly intervals this is day of the week. 1 - Sunday, 2 - Monday, 3 - Tuesday, etc. For monthly budgets this is the day of the month. 1st, 2nd, 3rd, etc. of the month. Defaults to 1.
| amount | float64 | yes | The budget limit |

#### Example Payload
```
{
    "name":"create-test",
    "filter":"",
    "kind":"soft",
    "interval":"weekly",
    "intervalDay":3,
    "amount":50
}
```

### Update Recurring Rule 

#### Expected Payload 
| Name | Type | Required? | Description |
|------|------|-----------|-------------|
| name | string | yes | The name of the budget rule |
| filter | string | no | The filter (either namespace or cluster) for the rule. Defaults to "". |
| kind | string | no | The type of budget. Takes either "hard" or "soft". Defaults to "soft" |
| interval | string | yes | The interval with which the budget is reset. Takes either "weekly" or "monthly" |
| intervalDay | int | no | The day the budget will reset. For weekly intervals this is day of the week. 1 - Sunday, 2 - Monday, 3 - Tuesday, etc. For monthly budgets this is the day of the month. 1st, 2nd, 3rd, etc. of the month. Defaults to 1.
| amount | float64 | yes | The budget limit |
| id | string | yes | The id of the budget rule to update |

#### Example Payload
```
{
    "name":"weekly-test-update",
    "filter":"",
    "kind":"soft",
    "interval":"weekly",
    "intervalDay":4,
    "amount":85
    "id":"4cf575d0-2d3f-4d86-bc1f-bd4e937da320"
}
```


## Delete Recurring Rules `http://<kubecost-address>/model/deleteRecurringBudgetRules`

This endpoint deletes a recurring budget rule, given an id as a parameter

### Parameters
| Name | Type | Description |
|------|------|-------------|
| `id` | string | Id of the recurring budget rule to be deleted | 

### API Example

```
// Delete budget
http://localhost:9090/model/deleteRecurringBudgetRules?id=783d69e7-97ce-4385-8cbe-fffdc8168bb9
```
