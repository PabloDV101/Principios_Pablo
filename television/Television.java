

/**
 * Class Television
 */
public class Television {

  //
  // Fields
  //

  public String forma;
  public String calidadDeVideo;
  protected String marca;
  private String tamaño;
  
  //
  // Constructors
  //
  public Television () { };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  /**
   * Set the value of forma
   * @param newVar the new value of forma
   */
  public void setForma (String newVar) {
    forma = newVar;
  }

  /**
   * Get the value of forma
   * @return the value of forma
   */
  public String getForma () {
    return forma;
  }

  /**
   * Set the value of calidadDeVideo
   * @param newVar the new value of calidadDeVideo
   */
  public void setCalidadDeVideo (String newVar) {
    calidadDeVideo = newVar;
  }

  /**
   * Get the value of calidadDeVideo
   * @return the value of calidadDeVideo
   */
  public String getCalidadDeVideo () {
    return calidadDeVideo;
  }

  /**
   * Set the value of marca
   * @param newVar the new value of marca
   */
  public void setMarca (String newVar) {
    marca = newVar;
  }

  /**
   * Get the value of marca
   * @return the value of marca
   */
  public String getMarca () {
    return marca;
  }

  /**
   * Set the value of tamaño
   * @param newVar the new value of tamaño
   */
  public void setTamaño (String newVar) {
    tamaño = newVar;
  }

  /**
   * Get the value of tamaño
   * @return the value of tamaño
   */
  public String getTamaño () {
    return tamaño;
  }

  //
  // Other methods
  //

  /**
   * @param        forma
   * @param        tamaño
   * @param        calidadDeVideo
   * @param        marca
   */
  public Television(String forma, String tamaño, String calidadDeVideo, String marca)
  
  {
	  this.forma=forma;
	  this.tamaño=tamaño;
	  this.calidadDeVideo=calidadDeVideo;
	  this.marca=marca;
	  System.out.println("Construyo una television");
  }


  /**
   */
  public void apacada()
  {
	  System.out.println("Television apagada");
  }


  /**
   */
  public void prendida()
  {
	  System.out.println("Television encendida");
  }


  /**
   * @param        forma
   */

  /**
   * @return       String
   */
 


}
