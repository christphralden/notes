>2024-07-06 22:15
>Tags: #architecture #refactoring
>Related: [[API Layer]], [[React-Query]], [[Self-Contained Components]], [[Atomic Design Pattern]]

---
# API Layer & Fetch Functions
Christopher Alden

Sources:
[Path To A Clean(er) React Architecture - Profy Dev](https://www.youtube.com/watch?v=tl6NuSL8euY)
<br>
## Context?

When creating a [[React]] component, it's best to have a mental model for [[Self-Contained Components]].
Basically a component should manage everything internally which includes the UI, state, data, and other related stuffs, or in other words encapsulated.

This is because React promotes Component Based Architecture, you can read more about this in [[Atomic Design Pattern]] which talks about how you can design better components for your React Application.

**But is your implementation correct?**

Some people might get the wrong idea and just dump a bunch of shit into one component and pray. That is not recommended.

>Lets take a look at this example:

```ts
export default function HotelRoomDetail(){
	const [queryParameters] = useSearchParams()
    const id =  queryParameters.get("hotelId")
    const [hotelRoomDetails, setHotelRoomDetails] = useState<HotelDetailsRoomDetails>()
	const [error, setError] = useState<Error|null>(null)
	
	useEffect(()=>{
		const fetchHotelRoomDetails = async () =>{
			try{
				const res = await apiClient
			.get('${API_ROUTES.getHotelRoomDetails}${encodeURIComponent(id)}')	
			
				// ... some business logic
				
				const data = res.data
				const transformedData = HotelRoomDetailsSchema.parse(data)		
				setHotelRoomDetails(transformedData)	
			}
			catch(error:any){
				setError(error)	
				alert(error)
			}
		}

		if(id){
			fetchHotelRoomDetails()
		}
	},[id])

	if(!id) return <Navigate to="/" />
	if(error) return null
	if(!hotel) return <Loading/>

	return(
		<>
			// ...UI Component
		</>
	)
}
```

---
## Whats wrong with this?

We can see in the UseEffect that business logic was exposed. At first glance, it might be hard to spot since the scope of the example is quite simple.

**The UI code, API code, business logics, are all inter-mingled with one another**

But imagine having multiple components, with multiple logic to maintain, with multiple states. It can get out of hand quickly, resulting in thousands of lines for a single component. One use case change and you're done for.

Yes we need Self-Contained Components, but in a way that is ==maintainable and scalable==

<br>

### 1. Tight Coupling of Fetching with UI

**It shouldn't matter how the IU gets the data, it just needs to know that the data will be served**

The UI should not give a single fuck on how the data is fetched, what the API endpoint is, is it a data stream using [[Web Sockets]], is it using REST or RPC, and any other extra steps.

We have to abstract and decouple the implementation by extracting functions to a separate place to be managed and maintained later on with respect to the scope of the feature.

> You would create a file `/api/hotel/hotel-room.ts` to encapsulate hotel-room logic.

```ts
// hotel-room.ts
export async function getHotelRoomDetails(id:number){
	const res = await apiClient
		.get('${API_ROUTES.getHotelRoomDetails}${encodeURIComponent(id)}')	
	
	// ... some business logic

	return res.data
}
```

```ts
export default function HotelRoomDetail(){
	const [queryParameters] = useSearchParams()
    const id =  queryParameters.get("hotelId")
        const [hotelRoomDetails, setHotelRoomDetails] = useState<HotelDetailsRoomDetails>()
	const [error, setError] = useState<Error|null>(null)
	
	useEffect(()=>{
		const fetchHotelRoomDetails = async () =>{
			try{
				// heres the change
				const res = await HotelRooms.getHotelRoomDetails(Number(id))
				
				// ... some business logic
				
				const data = res.data
				const transformedData = HotelRoomDetailsSchema.parse(data)		
				setHotelRoomDetails(transformedData)	
			}
			catch(error:any){
				setError(error)	
				alert(error)
			}
		}
			
		if(id){
			fetchHotelRoomDetails()	
		}
	},[id])

	if(!id) return <Navigate to="/" />
	if(error) return null
	if(!hotel) return <Loading/>

	return(
		<>
			...UI Component
		</>
	)
}
```

It might not seem much. But when considering larger scale application, using this pattern allows you to manage data fetching more efficiently and also decouples the relationship from the UI 

This promotes better reusability for the UI since it can be reused with slight modifications. The same goes for the data fetching function since it can be used for another component.


<br>

### 2. Not using [[React-Query]] to do [[Client-Side]] fetching is a crime.

**Enough said.**
<br>
### 3. Using [[Server-Side Rendering]] or [[Static-Site Generation]] to handle data fetching instead of Client-Side

**Its 2024.**