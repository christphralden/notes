>2024-07-07 00:37
>Tags: #react #react #architecture #api-layer
>Related:

---
# API Layer & Data Transformation
Christopher Alden

Sources:
[Path To A Clean(er) React Architecture - Profy Dev](https://www.youtube.com/watch?v=UaV_bPn1rWI)
<br>
## Context

In [[React]] After making a fetch, its important to save data to a state to maintain the data. It is not uncommon where we need to aggregate or destructure two or more data, or transform the response data into something the UI can take. 

That process is called [[Data Transformation]]

This usually takes place where [[TypeScript]] is involved, since we need to match the response data with the types we defined.

> Lets take a look at this example:

```ts
// feed.ts
export async function getFeed(){
	const res = await apiClient
			.get('${API_ROUTES.getFeed}${encodeURIComponent(id)}')	
	
	// ... some business logic

	return res.data
}
```


```tsx
export default function Feed(){
    const [feed, setFeed] = useState<FeedResponse>();
	const [error, setError] = useState<Error|null>(null)
	
	useEffect(()=>{
		const fetchFeed = async () =>{
			try{
				const res = await Feed.getFeed()
				setFeed(res.data)
			}
			catch(error:any){
				setError(error)	
				alert(error)
			}
		}
		fetchFeed()
	},[])

	if(!id) return <Navigate to="/" />
	if(error) return null
	if(!feed) return <Loading/>

	//... other data

	const users = feed.included.filter((u): u is User => u.type === "user")
	const images = feed.included.filter((i): i is Image => i.type === "image")
	return(
		<>
			<FeedComponent
				users = {users}
				image = {image}
			/>
		</>
	)
}
```

---
## What's wrong with this?

>Let us just assume some things such as the types since it differs with each implementation, and instead focus on addressing the issues.

### 1. UI is Tightly Coupled with Data Schema

**Extract the Data Transformation process respective to the Fetch Function**

Notice how the `users` and the `images`are processed first before being used?

In practical applications, we might use [[Zod]], where the the response is parsed and is attributes is ensured to match the schema we defined.

**But, what if we didn't use Zod?**

Well, it will probably result it some bad looking code like the example above and below.

> Heres an example of an abomination before the discovery of [[Data Transfer Objects]] and Zod

```ts
const addToCart = async () => {
        try {
            const completeTransaction: HotelTransactionPayload = {
                userId: user!.ID!, 
                price: calculatedPrice, 
                transactionDate: new Date(), 
                status: TransactionType.Cart, 
                hotelTransaction: {
                    checkInTime: hotelReservation.checkInTime,
                    checkOutTime: hotelReservation.checkOutTime,
                    hotelId: hotelReservation.hotelId,
                    roomDetailId: hotelReservation.roomDetailId,
                }
            }
            const response = await fetch(ApiEndpoints.HotelCompleteTransactionCreate, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(completeTransaction),
                credentials: 'include',
            });

            const data = await response.json()
            console.log(data.message)


        } catch (error) {
            console.error('Failed to create hotel transaction:', error);
            alert('Failed to create your reservation. Please try again.');
        }
    };
```

Looking back at [[API Layer & Fetch Functions]], the UI should not care that the data needs to be processed first, it expects served data is ready to be used. We want to minimize coupling since the UI should not have any knowledge of that.

**In the case that theres a change in the shape of the API response,  you're cooked.**

To solve this, we can move the Data Transformation into the Fetch Function, only serving data that is ready for the component.

```ts
export async function getFeed(){
	const res = await apiClient
			.get('${API_ROUTES.getFeed}${encodeURIComponent(id)}')	
	const data = res.data
	const transformedData = FeedSchema.parse(data)
	const {users, images} = transformedData
			
	return {users, images} 
}
```

```tsx
export default function Feed(){
    const [feed, setFeed] = useState<{
	   user: User[],
	   images: Images[]
    }>();
	const [error, setError] = useState<Error|null>(null)
	
	useEffect(()=>{
		const fetchFeed = async () =>{
			try{
				const data = await Feed.getFeed()
				setFeed(data)
			}
			catch(error:any){
				setError(error)	
				alert(error)
			}
		}
		fetchFeed()
	},[])

	if(!id) return <Navigate to="/" />
	if(error) return null
	if(!feed) return <Loading/>

	//... other data
	
	return(
		<>
			<FeedComponent
				users={feed.users}
				image={feed.image}
			/>
		</>
	)
}
```

**This can be applied to multiple implementations such as**
1. Form, where data needs to be transformed into `FormData` for the API request
2. Taking in multiple API request for one component, where you need to aggregate the data into one.
3. Destructuring like the example above