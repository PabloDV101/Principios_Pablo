
import java.util.*;


/**
 * Class Auto
 */
public class Auto {

  //
  // Fields
  //

  private String marca;
  
  //
  // Constructors
  //
  public Auto (String marca) { 
  this.marca=marca;
  };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

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

  //
  // Other methods
  //

}
