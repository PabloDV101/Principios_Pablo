
import java.util.*;


/**
 * Class Persona
 */
public class Persona {

  //
  // Fields
  //

  private String nombre;
  private Auto auto;
  
  //
  // Constructors
  //
  public Persona (String nombre, Auto auto) {
 	this.nombre=nombre;
	this.auto=auto;
  };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  /**
   * Set the value of nombre
   * @param newVar the new value of nombre
   */
  public void setNombre (String newVar) {
    nombre = newVar;
  }

  /**
   * Get the value of nombre
   * @return the value of nombre
   */
  public String getNombre () {
    return nombre;
  }

  /**
   * Set the value of auto
   * @param newVar the new value of auto
   */
  public void setAuto (Auto newVar) {
    auto = newVar;
  }

  /**
   * Get the value of auto
   * @return the value of auto
   */
  public Auto getAuto () {
    return auto;
  }

  //
  // Other methods
  //

  /**
   */
  public void mostrarAuto()
  {
	  System.out.println(nombre+" tiene un "+auto.getMarca());
  }


}
