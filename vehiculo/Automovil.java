

/**
 * Class Automovil
 */
public class Automovil extends Vehiculo {

  //
  // Fields
  //

  private int numAsientos;
  private int numPuertas;
  
  //
  // Constructors
  //
  public Automovil (String marcaModelo, int precioDia, int numllantas,
		  int numAsientos, int numPuertas) {
 	super(marcaModelo,precioDia,numllantas);
	this.numAsientos=numAsientos;
	this.numPuertas=numPuertas;
  };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  /**
   * Set the value of numAsientos
   * @param newVar the new value of numAsientos
   */
  public void setNumAsientos (int newVar) {
    numAsientos = newVar;
  }

  /**
   * Get the value of numAsientos
   * @return the value of numAsientos
   */
  public int getNumAsientos () {
    return numAsientos;
  }

  /**
   * Set the value of numPuertas
   * @param newVar the new value of numPuertas
   */
  public void setNumPuertas (int newVar) {
    numPuertas = newVar;
  }

  /**
   * Get the value of numPuertas
   * @return the value of numPuertas
   */
  public int getNumPuertas () {
    return numPuertas;
  }

  //
  // Other methods
  //

  /**
   */
  public void mostrarDatos()
  {
	System.out.println("marca: "+marcaModelo);
	System.out.println("Precio: "+precioDia);
	System.out.println("numero de llantas: " +numllantas);
	System.out.println("numero de asientos: "+numAsientos);
	System.out.println("numero de puertas: "+numPuertas);

  }


  /**
   */
  public void pruebaDelMotor()
  {
	  System.out.println("Probando motor del automovil");
  }


}
