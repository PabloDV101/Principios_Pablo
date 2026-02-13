

/**
 * Class Avion
 */
public class Avion {

  //
  // Fields
  //

  public String capacidad;
  protected String velocidad;
  private String aereolinea;
  private String cantidadDeMotores;
  
  //
  // Constructors
  //
  public Avion () { };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  /**
   * Set the value of capacidad
   * @param newVar the new value of capacidad
   */
  public void setCapacidad (String newVar) {
    capacidad = newVar;
  }

  /**
   * Get the value of capacidad
   * @return the value of capacidad
   */
  public String getCapacidad () {
    return capacidad;
  }

  /**
   * Set the value of velocidad
   * @param newVar the new value of velocidad
   */
  public void setVelocidad (String newVar) {
    velocidad = newVar;
  }

  /**
   * Get the value of velocidad
   * @return the value of velocidad
   */
  public String getVelocidad () {
    return velocidad;
  }

  /**
   * Set the value of aereolinea
   * @param newVar the new value of aereolinea
   */
  public void setAereolinea (String newVar) {
    aereolinea = newVar;
  }

  /**
   * Get the value of aereolinea
   * @return the value of aereolinea
   */
  public String getAereolinea () {
    return aereolinea;
  }

  /**
   * Set the value of cantidadDeMotores
   * @param newVar the new value of cantidadDeMotores
   */
  public void setCantidadDeMotores (String newVar) {
    cantidadDeMotores = newVar;
  }

  /**
   * Get the value of cantidadDeMotores
   * @return the value of cantidadDeMotores
   */
  public String getCantidadDeMotores () {
    return cantidadDeMotores;
  }

  //
  // Other methods
  //

  /**
   * @param        aereolinea
   * @param        cantidadDeMotores
   * @param        velocidad
   * @param        capacidad
   */
  public Avion(String aereolinea, String cantidadDeMotores, String velocidad, String capacidad)
  {
	this.aereolinea=aereolinea;
	this.cantidadDeMotores=cantidadDeMotores;
	this.velocidad=velocidad;
	this.capacidad=capacidad;
	System.out.println("Construyo un avion");
  }


  /**
   */
  public void acelerar()
  {
	  System.out.println("El avion acelero");
  }


  /**
   */
  public void elevarse()
  {
	  System.out.println("El avion se elevo");
  }


}
