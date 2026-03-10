

/**
 * Class Main
 */
public class Main {

  //
  // Fields
  //

  
  //
  // Constructors
  //
  public Main () { };
  
  //
  // Methods
  //
public static void main(String [] args){
	Pelota pelota1 = new Pelota("redonda","azul","plastico","suave");
	pelota1.botar();
	pelota1.desinflar();
	Pelota pelota2 = new Pelota("cuadrada","roja","cuero","dura");
	pelota2.botar();
	pelota2.desinflar();
}
  //
  // Accessor methods
  //

  //
  // Other methods
  //

}
