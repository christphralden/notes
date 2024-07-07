>2024-07-07 16:00
>Tags:
>Related:

---
# Compound Components
Christopher Alden

Sources:
<br>
## Context?

When creating a complicated UI, often we break it into chunks of components, as mentioned in [[Atomic Design Pattern]]. More often than not, you find yourself having hundreds of components and drilling props into multiple child components.

### Introducing [[Context API]]

Now the first thought that comes to mind is solving this using Context API to maintain a shared state across your related components. This is true, but depending on your implementation this might not scale well.

>Lets say something interactive and complicated like a navbar dropdown with additional menu groups

![[Screenshot 2024-07-07 at 16.28.06.png]]<br>
That's a single context created just for managing a navbar. Imagine how you would manage it if there are multiple complex component tree.

### Why you should rethink your approach

1. **Performance Issue**. We've come to terms that state management isn't most optimal thing in [[React]]. Using Context to rescue you would potentially cause unnecessary re-renders if your faced with skill-issue, especially in a bigger component tree.

2. **Overusing Context API** is also a problem especially if you're not doing it right. Yes its damn convenient to use, but this can lead to tight coupling between components. If you are not familiar with the code base, who would've thought that `<ComponentA/>` and `<ComponentZ/>` should **ONLY** be used together under the provider of `<ContextC/>`. Especially with naming issues.

3. **Scaling**. When any implementation of any child in the component tree changes, you're cooked. You find yourself changing the structure and the code of the corresponding context, while effectively not doing much since you're only fixing it for a child component.

**Using Context API isn't wrong. But there are patterns to better your approach in designing a component**
<br>
**Great now we understand the issues of spreading around components and context. How do we make that more manageable?**

---
## Compound Components
<br>

### Create the base component

>Lets make a simple navbar component without Compound Components to see the difference

```ts
// navbar-routes.ts
export const NavbarRoutes = [
	{
		name:"nav1",
		content: <Nav1Content/>	
	},
	{
		name:"nav2",
		content: <Nav2Content/>	
	}
]
```

```tsx
// navbar.tsx
export default function Navbar = () => {
	const [activeGroup, setActiveGroup] = useState<number>(0)
	const handleGroupClick = (index) =>{
		setActiveGroup(index)	
	}

	return{
		<>
		<div>
			<div>
				<Logo/>
			</div>
			<div> // imagine this is the Navbar Menus
				{NavbarRoutes.map((nav, index)=>{
					<div
						key={index}
						onClick={()=>handleGroupClick(index)}	
						className={}
					>{nav.name}</div>
				})}
			<div>
		</div>	
		<div> // Imagine this shows the Items inside the Navbar Menus
			{NavbarRoutes.map((nav, i)=>{
				<div
					className={`${activeGroup == i ? 'block' : 'invisible'}`}
				>
					{nav.content}
				</div>	
			})}
		<div>
		<>
	}
}
```
<br>

### Create the Context

>We are still using Context API since we need a shared state, but with a few changes in the implementation

```tsx
// navbar-context.tsx
interface NavbarContextProps{
	activeGroup: number;
	hanldeGroupClick: () => void;
}

const function NavbarContext = createContext<NavbarContextProps | null>(
	null
)

export function NavbarContextProvider({children}:{
	children:ReactNode
}) {
	const [activeGroup, setActiveGroup] = useState<number>(0)
	
	function handleGroupClick{
		setActiveGroup(index)	
	}

	return(
		<NavbarContext.Provider 
			value={{
				activeGroup, 
				handleGroupClick
			}}
		>
			{children}
		</NavbarContext.Provider>
	)
}

//create the hook to use the context
export const useNavbarContext = () =>{
	const context = useContext(NavbarContext)

	if(!context){
		throw new ContextError("Message") //create by extending error
	}

	return context;
}
```

Notice how we created a hook to use the context? This practice should be implemented in every Context you make.
<br>
### Compose into Compound Components

Now that you've got the building blocks we can create the compound components.
Remember that this flow is only used for example. To streamline this you can first create the context then the component.

We will do slight refactoring to make the components more modular and dynamic.

```tsx
// navbar.tsx
export function Navbar = ({rest, className}:{
	rest: ReactNode
	className: string
}) => {
	return{
		<NavbarContextProvider>
			<div className={cn('default styling', className)}>
				{...rest}
			<div>
		</NavbarContextProvider>
	}
}
```

```tsx
// child components
export function NavbarLogo({children}:{
	src:string
}) {
	return(
		<div className={}>
			<Image
				src={src}
				alt={src}
			/>
		</div>
	)
}

export function NavbarItem = ({label, children}:{
	label:string
	children:ReactNode
}){
	return(
		<>{children}</>
	)
}

export function NavbarItems = ({label, children}:{
	children:ReactNode
	className: string
}){
	const {activeGroup, handleGroupClick} = useNavbarContext();

	return(
		<>
			<div classname={cn('default styling',classname)}>
				{react.children.map(children, (child, i)=>{
					<Button
						key={i}
						onclick={()=>handleGroupClick(i)}
						classname={}
					>
						{child.props.label}
					</Button>	
				})}
			</div>
			<div>
				{React.Children.map(children, (child, i)=>{
					<div
						className={`${activeGroup == i ? 'block' : 'invisible'}`}
					>
						{child}
					</div>	
				})}
			</div>
		</>
	)
}

export const Navbar = Object.assing(Navbar, {
	Logo: NavbarLogo,
	Item: NavbarItem,
	Items: NavbarItems
})
```

Great now we can use it like this

```tsx
export default function Page(){
	return(
		<Navbar className="flex justify-between items-center">
			<Navbar.Logo src={myLogo}/>
			<Navbar.Items>
				<Navbar.Item label='nav1'>
					<div>Nav1 Content<div>
				</Navbar.Item>
				<Navbar.Item label='nav2'>
					<div>Nav2 Content<div>
				</Navbar.Item>
			</Navbar.Items>
		</Navbar>
	)
}
```

---
## When not to use

Congratulations you've end up with some boilerplates, more code, and some enterprisey code

1. **Simple Components**. Do not over-engineer your application. [[KISS]], Keep It Simple Stupid.
2. **Fast Iterations**. If you don't know how your component will look or iterate, don't build on this. Make sure you know how its designed and its functionality, then refactor to this pattern.

**I did not test the code its purely for example, example used was also just to demonstrate the pattern. Only use when a component needs shared state, complex functionality, and is closely related**