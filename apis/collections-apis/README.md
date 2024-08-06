# Collections APIs

Kubecost's Collections APIs allow users to manage their collections and query various kinds of costs for collections and categories of collections.

## Table of Contents

### Introduction to collections
1. [How a collection is defined](#how-a-collection-is-defined)
1. [How to build a collection](#how-to-build-a-collection)
1. [How to query collections](#how-to-query-collections)

### Managing collections
1. [List collections](list.md)
1. [View a collection](view.md)
1. [Create a new collection](create.md)
1. [Update an existing collection](update.md)
1. [Delete a collection](delete.md)

### Querying Collections
1. [Query collection total costs](collection-total.md)
1. [Query collection time series costs](collection-timeseries.md)
1. [Query collection complement costs](collection-complement.md)
1. [Query category total costs](category-total.md)
1. [Query category time series costs](category-timeseries.md)
1. [Query category complement costs](category-complement.md)

## Introduction to collections

Kubecost collections offer organizations a way to build flexible and composite structures for tracking all infrastructure costs belonging to various teams, departments, or other groups within any organization, particularly when those costs come from a variety of sources like Kubernetes clusters, Amazon S3 buckets, GCP Cloud Run jobs, etc. In short, collections allow every organization to bring together and accurately allocate all of their infrastructure costs, in a way that fits the organization's own structure.

### How a collection is defined

A collection is defined by a set of zero or more "groups," each of which represents a cost that is defined by a "selector," which is just a filter pertaining to some domain of costs. Whatever costs are selected by each of the groups in a given collection will be aggregated (and de-duped, if they happen to select the same cost) and attributed to the collection's own total costs.

Furthermore, a collection can belong to a category, which helps for organizing and querying similar kinds of collections. 

A brief example will help to clarify these concepts.

### How to build a collection

We begin with an empty collection, which only has a name, and in this case a category:

```json
{
    "name": "Infrastructure",
    "category": "Team"
}
```

Such a collection might represent an organization's infrastructure team. To get use out of the category, other collections with `"category": "Team"` could be created, like the QA team, or the Engineering team.

To track costs associated with this team, we can add a group. In this case, we'll add the costs belonging to the `infrastructure` namespace in any of the Kubernetes clusters being monitored:

```json
{
    "name": "Infrastructure",
    "category": "Team", 
    "groups": [
        {
            "selectors": {
                "kubernetes": {
                    "kind": "container",
                    "filterString": "namespace:\"infrastructure\""
                }
            }
        }
    ]
}
```

Furthermore, we can add a group for costs belonging to workloads tagged with the label `team=infrastructure` across any of the Kubernetes clusters being monitored:

```json
{
    "name": "Infrastructure",
    "category": "Team", 
    "groups": [
        {
            "selectors": {
                "kubernetes": {
                    "kind": "container",
                    "filterString": "namespace:\"infrastructure\""
                }
            }
        },
        {
            "selectors": {
                "kubernetes": {
                    "kind": "container",
                    "filterString": "label[team]:\"infrastructure\""
                }
            }
        }
    ]
}
```

What if there are workloads in the `infrastructure` namespace, which also have the `team=infrastructure` label? Will these costs be duplicated? No, queries for the cost of this collection will mindfully detect and dedupe those overlapping costs.

Finally, we can add a group representing costs from all of the Amazon EC2 instances that have the label `team=infrastructure`:

```json
{
    "name": "Infrastructure",
    "category": "Team", 
    "groups": [
        {
            "selectors": {
                "kubernetes": {
                    "kind": "container",
                    "filterString": "namespace:\"infrastructure\""
                }
            }
        },
        {
            "selectors": {
                "kubernetes": {
                    "kind": "container",
                    "filterString": "label[team]:\"infrastructure\""
                }
            }
        },
        {
            "selectors": {
                "cloud": {
                    "filterString": "service:\"AmazonEC2\"+label[team]:\"infrastructure\""
                }
            }
        }
    ]
}
```

Once again, if some of those EC2 instances are, in fact, Kubernetes nodes that run workloads identified by the previous two groups, there is no need to worry about duplicate costs. Collections queries will detect the overlap and dedupe costs accordingly, maintaining an accurate record of the overall cost associated with the collection.

This same process can be carried out for multiple other teams, or other categories of collections, at which point the query APIs will provide a rich and insightful picture into the breakdown of overall costs in the organization.

### How to query collections

Three kinds of costs associated with collections can be queried over a given window of time:

1. All of the costs included in a collection, i.e., the total costs
1. All of the costs included in a collection, presented over time, i.e., the time series costs
1. All of the costs NOT included in a collection, i.e., the complement costs

Furthermore, each of these kinds of costs can be queried for a category, incluing each collection in the category, as opposed to a single collection. (For instance, if you want to see all of the costs NOT included in ANY of the "Team" collections, you can query the complement costs of the "Team" category.)

A brief query example will illustrate the power of collections.

We can query total costs of the infrastructure team over the month of January 2023, and get the following result: 

```json
{
    "id": "8a939ba1-ff15-4600-b711-2cb109114914",
    "name": "Infrastructure",
    "category": "Team", 
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "data": {
        "cost": {
            "totalCost": 60.0,
            "idleCost": 10.0,
            "domainCosts": {
                "kubernetesCost": {
                    "totalCost": 40.0,
                    "idleCost": 10.0
                },
                "cloudCost": {
                    "totalCost": 20.0
                }
            },
        },
    }
}
```

Here we see that the infrastructure team spent $60.00 total, $40 of which is from Kubernetes, and $20 of which is general "cloud cost" spend -- possibly EC2 instances or S3 buckets.

If we want to see a breakdown by group within the collection, we can also see that by passing an optional parameter:

```json
{
    "id": "8a939ba1-ff15-4600-b711-2cb109114914",
    "name": "Infrastructure",
    "category": "Team", 
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "data": {
        "cost": {
            "totalCost": 60.0,
            "idleCost": 10.0,
            "domainCosts": {
                "kubernetesCost": {
                    "totalCost": 40.0,
                    "idleCost": 10.0
                },
                "cloudCost": {
                    "totalCost": 20.0
                }
            },
        },
        "overlap": -10.0,
        "groups": [
            {
                "selectors": {
                    "kubernetes": {
                        "kind": "container",
                        "filterString": "namespace:\"infrastructure\""
                    }
                },
                "cost": {
                    "totalCost": 30.0,
                    "idleCost": 5.0,
                    "domainCosts": {
                        "kubernetesCost": {
                            "totalCost": 30.0,
                            "idleCost": 5.0
                        },
                    }
                }
            },
            {
                "selectors": {
                    "kubernetes": {
                        "kind": "container",
                        "filterString": "label[team]:\"infrastructure\""
                    }
                },
                "cost": {
                    "totalCost": 20.0,
                    "idleCost": 5.0,
                    "domainCosts": {
                        "kubernetesCost": {
                            "totalCost": 20.0,
                            "idleCost": 5.0
                        }
                    }
                }
            },
            {
                "selectors": {
                    "cloud": {
                        "filterString": "service:\"AmazonEC2\"+label[team]:\"infrastructure\""
                    }
                },
                "cost": {
                    "totalCost": 20.0,
                    "domainCosts": {
                        "cloudCost": {
                            "totalCost": 20.0
                        }
                    }
                }
            }
        ]
    }
}
```

Now it's more clear where the money is being spent. But it is also clear how these groups overlap slightly. The field `"overlap": -10.0` indicates that, between the three groups, $10.00 of cost was double-counted. The query detected and deduped that cost, as it pertains to the total cost, but is the full cost of each group for full transparency.

There are many more examples of each kind of query that can be made with collections. Please see the navigation, or the [Table of Contents](#table-of-contents) above, for reference.