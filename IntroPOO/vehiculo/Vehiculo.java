

/**
 * Class Vehiculo
 */
public class Vehiculo {

  //
  // Fields
  //

  protected int precioDia;
  protected String marcaModelo;
  protected int numllantas;
  
  //
  // Constructors
  //
  public Vehiculo (String marcaModelo, int precioDia, int numllantas) {
 this.marcaModelo=marcaModelo;
 this.precioDia=precioDia;
 this.numllantas = numllantas;
 
  };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  /**
   * Set the value of precioDia
   * @param newVar the new value of precioDia
   */
  public void setPrecioDia (int newVar) {
    precioDia = newVar;
  }

  /**
   * Get the value of precioDia
   * @return the value of precioDia
   */
  public int getPrecioDia () {
    return precioDia;
  }

  /**
   * Set the value of marcaModelo
   * @param newVar the new value of marcaModelo
   */
  public void setMarcaModelo (String newVar) {
    marcaModelo = newVar;
  }

  /**
   * Get the value of marcaModelo
   * @return the value of marcaModelo
   */
  public String getMarcaModelo () {
    return marcaModelo;
  }

  /**
   * Set the value of numllantas
   * @param newVar the new value of numllantas
   */
  public void setNumllantas (int newVar) {
    numllantas = newVar;
  }

  /**
   * Get the value of numllantas
   * @return the value of numllantas
   */
  public int getNumllantas () {
    return numllantas;
  }

  //
  // Other methods
  //

  /**
   */
  public void mostrarCaracteristicas()
  {
  }


  /**
   */
  public void encenderMotor()
  {
  }


  /**
   */
  public void apagarMotor()
  {
  }


  /**
   */
  public void funciona()
  {
  }


}
