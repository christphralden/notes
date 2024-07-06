>2024-07-06 20:27
>Tags:
>Related:

---
# Shared API Client
Christopher Alden

Sources:
[Path To A Clean(er) React Architecture - Profy Dev](https://www.youtube.com/watch?v=GpRYT3CQ-Y0)

### Context?

When creating a react application, we often use API to communicate our backend with our frontend.
This is usually located in the network layer of our application

>Using basic React WebApp structure

```
\src
	\app
	\lib
		\components
		\api
			foo.tsx	
```

>You might even structure on each feature

```
\src
	\app
	\lib
		\features
			\auth
				index.tsx
				user-info.tsx
```

>Or you have a service that you have to connect to, and however other ways you structure your project.

**We might see a code that looks like this:**

```ts
// hotel-room.ts
export async function getRoomDetails(id:number): Promise<RoomDetail>{
	const url = 'api/hotel/room/${encodeURIComponent(id)}'
	const res = await fetch(url)
	const data = await res.json()
	if (!res.ok) throw new Error("Error Message")
	return data
}
```

```ts
// hotel-room.ts
export async function createRoomDetail(roomDetails:RoomDetails[]{
	const res = await fetch('api/hotel/room/create',{
		method: "POST",
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(roomDetails),
		credentials: 'include'
	})
	const data = await res.json()
	if(!res.ok) throw new Error("Error Message")
	alert(res.message)
}
```

---
### What's wrong with this?

>You can clearly see a few problems in this shit code,
>Lets review some things that should be changed and why.

<br>

##### 1. Magic Variables

**It is better to keep the routes in a centralized file within the scope.**

API routes are hard coded into the functions making it hard to manage if theres a breaking change in code.

>Lets say `api/hotel/room/create` is changed to `api/v2/hotel/room/create`

You would have to find the related API route distributed across your code base, which is not fun.
<br>

##### 2. Shared API Client

**To increase modularity, use a shared API client when making a request.**

Using the same example:
>Lets say `api/hotel/room/create` is changed to `api/v2/hotel/room/create`

We notice that in this case be baseURL is changed from `api/` to `api/v2`.
This often happens when a new service is created and the application wants to use a newer version of an API.

Essentially, even if we create some form of map or enum as mentioned on the solution for [[#1. Magic Variables]], It is still susceptible to breaking change since technically, it's still a hardcoded string. Just centralized for management

So we can handle this by specifying a sort of client to provide us a way to create new requests.

```ts
// api/client.ts
const API_BASE_URL = "api/"

export async function apiClient(endpoint:string, options:{} = {}){
	const config = {
		method: "GET" // default is set to GET
		...options,
		headers: { 'Content-Type': 'application/json' },
		...(options.headers || {}),
	}

	return fetch('${API_BASE_URL}${endpoint}', config)
}
```

> That is just a simplified implementation to give an overview.
> You can leverage [[Axios]] for this and refer to their documentation.

This ensures that a consistent and default setup for API's you are going to use.
Using this pattern also enables us to dynamically add middleware and other specific configurations needed.

**Lets extend from the example to a full implementation**

```ts
// api-client.ts
class APIClient{
	constructor(baseURL:string){
		this.baseURL = baseURL	
	}

	async request(url:string, options:string){
		const res = await fetch('${this.baseURL}${url}', options)
		if(!res.ok){
			const error = new HTTPError("Error Message"); // create this by extending Error
			error.status = response.status
			error.response = await res.json()
			throw error
		}
		return res.json()
	}

	get(url){
		return this.request(url,{
			method: "GET",
			headers: { 'Content-Type': 'application/json' },
		})	
	}

	post(url:string, data:{}){
		return this.request(url,{
			method: "POST",
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(data)	
		})	
	}

	// implement more methods as needed
}
```

---

Now managing network requests is more scalable and has a better DX. 

**Keep in mind that I also have no fucking clue**