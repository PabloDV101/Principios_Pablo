public class Director{
public House construct(HouseBuilder builder){
	builder.buildWalls();
	builder.buildRoof();
	builder.buildGarage();
	return builder.getHouse();
	
}

}
