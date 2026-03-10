

/**
 * Class Motocicleta
 */
public class Motocicleta extends Vehiculo {

  //
  // Fields
  //

  private int numAsientos;
  
  //
  // Constructors
  //
  public Motocicleta (String marcaModelo,int precioDia,int numllantas,int numAsientos) 
  {
 	super(marcaModelo,precioDia,numllantas);
	this.numAsientos=numAsientos;
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

  //
  // Other methods
  //

  /**
   */
  public void mostrarDatos()
  {
	  System.out.println("marca: "+marcaModelo);
	  System.out.println("precio: "+precioDia);
	  System.out.println("numero de llantas: "+numllantas);
	  System.out.println("numero de asientos: "+numAsientos);
  }


  /**
   */
  public void pruebaDelMotor()
  {
	  System.out.println("Se prueba el motor de la moto");
  }


}
