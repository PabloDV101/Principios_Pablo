

/**
 * Class Motor
 */
public class Motor {

  //
  // Fields
  //

  private String tipo;
  
  //
  // Constructors
  //
  public Motor (String tipo) {
 this.tipo=tipo;
  };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  /**
   * Set the value of tipo
   * @param newVar the new value of tipo
   */
  public void setTipo (String newVar) {
    tipo = newVar;
  }

  /**
   * Get the value of tipo
   * @return the value of tipo
   */
  public String getTipo () {
    return tipo;
  }

  //
  // Other methods
  //

  /**
   */
  public void encender()
  {
	  System.out.println("Motor "+tipo+" encendido...");
  }


}
