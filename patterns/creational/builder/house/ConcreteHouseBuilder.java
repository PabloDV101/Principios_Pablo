public class ConcreteHouseBuilder implements HouseBuilder{
	
	private House house = new House();

	public void buildWalls(){
		house.setWalls("ladrillo");
	}
	public void buildRoof(){
		house.setRoof("tejas");
	}
	public void buildGarage(){
		house.setGarage(true);
	}
	public House getHouse(){
		return house;
	}
	
	
}
