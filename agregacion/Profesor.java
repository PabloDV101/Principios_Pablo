
import java.util.*;


/**
 * Class Profesor
 */
public class Profesor {

  //
  // Fields
  //

  private String nombre;
  private String especialidad;
  
  //
  // Constructors
  //
  public Profesor () { };
  
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
   * Set the value of especialidad
   * @param newVar the new value of especialidad
   */
  public void setEspecialidad (String newVar) {
    especialidad = newVar;
  }

  /**
   * Get the value of especialidad
   * @return the value of especialidad
   */
  public String getEspecialidad () {
    return especialidad;
  }

  //
  // Other methods
  //

  /**
   * @param        nombre
   * @param        especialidad
   */
  public Profesor(String nombre, String especialidad)
  {
	  this.nombre=nombre;
	  this.especialidad=especialidad;
  }


}
