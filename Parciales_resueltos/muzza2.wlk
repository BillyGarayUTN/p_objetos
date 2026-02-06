// Sistema Muzza 5K - Pizzerías de Corrientes

///////////////  PIZZAS ///////////////

class Pizza {
    var property ingredientes = []
    
    method porciones() = 8
    
    method costo() = self.cantidadLetrasIngredientes() * 100
    
    method cantidadLetrasIngredientes() = 
        ingredientes.sum { ingrediente => ingrediente.size() }
    
    method agregarIngrediente(nuevoIngrediente) {
        ingredientes.add(nuevoIngrediente)
    }
    
    method puedeAgregarPizza(pizza) = true  // Pizza normal siempre puede
    
    
}

class PizzaChica inherits Pizza {
    override method porciones() = 4  // Mitad de pizza normal
    
    override method costo() = super() * 0.75  // 3/4 partes del costo normal
    
    
}

class PizzaCompuesta inherits Pizza {
    var property pizzasComponentes = []
    
    // Las porciones son el mínimo de las pizzas que la componen
    override method porciones() {
        if (pizzasComponentes.isEmpty()) return 0
        return pizzasComponentes.min { pizza => pizza.porciones() }
    }
    
    // El costo es el de la pizza más costosa que la compone
    override method costo() {
        if (pizzasComponentes.isEmpty()) return 0
        return pizzasComponentes.max { pizza => pizza.costo() }
    }
    
    // No puede tener más pizzas que porciones disponibles
    override method puedeAgregarPizza(pizza) = 
        pizzasComponentes.size() < self.porciones()
    
    method agregarPizza(pizza) {
        if (self.puedeAgregarPizza(pizza)) {
            pizzasComponentes.add(pizza)
        } else {
            self.error("No se puede agregar más pizzas, excede las porciones disponibles")
        }
    }
    
    // Cuando se agrega ingrediente a compuesta, se agrega a todos los componentes
    override method agregarIngrediente(nuevoIngrediente) {
        super(nuevoIngrediente)  // Agregar a la compuesta misma
        pizzasComponentes.forEach { pizza => pizza.agregarIngrediente(nuevoIngrediente) }
    }
    
    // La cantidad de letras incluye las de los componentes
    override method cantidadLetrasIngredientes() = 
        super() + pizzasComponentes.sum { pizza => pizza.cantidadLetrasIngredientes() }
    
}

///////////////  PIZZERÍAS ///////////////

class Pizzeria {
    const property nombre
    const property costoBase
    const property factorChetez
    var property estilo = new EstiloNormal()  // PUNTO 3: Estilo modificable
    var property historialEntregas = []       // PUNTO 5: Historial para consultas
    
    // PUNTO 1: Fórmula principal del negocio
    method precioFinal(pizza) = (pizza.costo() + costoBase) * factorChetez
    
    // Factory methods para crear pizzas
    method crearPizzaEstandar(ingredientes) {
        const pizza = new Pizza()
        ingredientes.forEach { ingrediente => pizza.agregarIngrediente(ingrediente) }
        return pizza
    }
    
    method crearPizzaChica(ingredientes) {
        const pizza = new PizzaChica()
        ingredientes.forEach { ingrediente => pizza.agregarIngrediente(ingrediente) }
        return pizza
    }
    
    method crearPizzaCompuesta(pizzas) {
        const pizza = new PizzaCompuesta()
        pizzas.forEach { p => pizza.agregarPizza(p) }
        return pizza
    }
    
    // PUNTO 2: Calcular precio de un pedido completo
    method precioPedido(pedido) = 
        pedido.pizzas().sum { pizza => self.precioFinal(pizza) }
    
    // PUNTO 3: Crear entrega a partir de un pedido
    method crearEntrega(pedido) {
        const precioDelPedido = self.precioPedido(pedido)
        const ejecucion = estilo.procesarPedido(pedido, self)
        const precioFinal = ejecucion.sum { pizza => self.precioFinal(pizza) }
        
        const entrega = new Entrega(
            pedidoOriginal = pedido,
            precioDelPedido = precioDelPedido,
            ejecucion = ejecucion,
            precioFinal = precioFinal
        )
        
        // PUNTO 5: Registrar en historial
        historialEntregas.add(entrega)
        
        return entrega
    }
    
    // PUNTO 5: Cliente con más pizzas entregadas
    method clienteConMasPizzasEntregadas() {
        if (historialEntregas.isEmpty()) return null
        
        // Crear mapa de clientes y sus pizzas totales
        const clientesPizzas = #{}
        
        historialEntregas.forEach { entrega =>
            const cliente = entrega.pedidoOriginal().cliente()
            const pizzasEntregadas = entrega.cantidadPizzasEntregadas()
            
            if (clientesPizzas.containsKey(cliente)) {
                clientesPizzas.put(cliente, clientesPizzas.get(cliente) + pizzasEntregadas)
            } else {
                clientesPizzas.put(cliente, pizzasEntregadas)
            }
        }
        
        // Encontrar el cliente con más pizzas
        var clienteMaximo = null
        var maxPizzas = 0
        
        clientesPizzas.forEach { cliente, cantidad =>
            if (cantidad > maxPizzas) {
                maxPizzas = cantidad
                clienteMaximo = cliente
            }
        }
        
        return clienteMaximo
    }
    
    // Servicios de la pizzería
    method agregarIngredienteAPizza(pizza, ingrediente) {
        pizza.agregarIngrediente(ingrediente)
    }
    
    method cambiarEstilo(nuevoEstilo) {
        estilo = nuevoEstilo
    }
    
}

///////////////  CLIENTES ///////////////

class Cliente {
    const property nombre
    var property nivelHumor = 5  // Valor inicial neutro (1-10)
    
    method recibirEntrega(estaConforme) {
        if (estaConforme) {
            nivelHumor = (nivelHumor + 1).min(10)  // Límite superior
        } else {
            nivelHumor = (nivelHumor - 1).max(1)   // Límite inferior
        }
    }
    
    method estaContento() = nivelHumor >= 7
    method estaTriste() = nivelHumor <= 3
    method estaRelajado() = nivelHumor == 5
    
    // PUNTO 4: Evaluar conformidad con la entrega
    method evaluarEntrega(entrega)  // Método abstracto
    
    // PUNTO 4: Hacer pedido y recibir entrega
    method hacerPedido(pedido, pizzeria) {
        const entrega = pizzeria.crearEntrega(pedido)
        const estaConforme = self.evaluarEntrega(entrega)
        self.recibirEntrega(estaConforme)
        return entrega
    }
    
    override method toString() = 
        nombre + " (Humor: " + nivelHumor + "/10)"
}

// PUNTO 4: Tipos de clientes

class ClienteSuperExigente inherits Cliente {
    
    override method evaluarEntrega(entrega) {
        const pedidoOriginal = entrega.pedidoOriginal().pizzas()
        const ejecucion = entrega.ejecucion()
        
        // Debe ser exactamente lo mismo
        if (pedidoOriginal.size() != ejecucion.size()) return false
        
        // Comparar cada pizza (simplificado: por ingredientes)
        return (0..(pedidoOriginal.size() - 1)).all { i =>
            self.mismaPizza(pedidoOriginal.get(i), ejecucion.get(i))
        }
    }
    
    method mismaPizza(pizza1, pizza2) {
        return pizza1.ingredientes().asSet() == pizza2.ingredientes().asSet()
    }
}

class ClienteHumilde inherits Cliente {
    
    override method evaluarEntrega(entrega) {
        // Conforme si el costo de lo entregado >= lo que pidió
        return entrega.precioFinal() >= entrega.precioDelPedido()
    }
}

class ClienteManoso inherits Cliente {
    const property ingredienteOdiado
    
    override method evaluarEntrega(entrega) {
        // Conforme si ninguna pizza entregada tiene el ingrediente odiado
        return entrega.ejecucion().all { pizza =>
            !pizza.ingredientes().contains(ingredienteOdiado)
        }
    }
}

///////////////  PEDIDOS ///////////////

class Pedido {
    var property pizzas = []
    const property cliente
    const property pizzeria
    
    method agregarPizza(pizza) {
        pizzas.add(pizza)
    }
    
    method costoTotal() = 
        pizzas.sum { pizza => pizzeria.precioFinal(pizza) }
    
    method cantidadPorciones() = 
        pizzas.sum { pizza => pizza.porciones() }
    
    method pizzaMasCara() {
        if (pizzas.isEmpty()) return null
        return pizzas.maxIf { pizza => pizzeria.precioFinal(pizza) }
    }
    
    method pizzaMasBarata() {
        if (pizzas.isEmpty()) return null
        return pizzas.minIf { pizza => pizzeria.precioFinal(pizza) }
    }
    
    method entregarPedido(conformidad) {
        cliente.recibirEntrega(conformidad)
    }
    
    method esPedidoGrande() = self.cantidadPorciones() > 20
    
    override method toString() = 
        "Pedido de " + cliente.nombre() + " en " + pizzeria.nombre() + 
        " (" + pizzas.size() + " pizzas, $" + self.costoTotal() + ")"
}

///////////////  ENTREGAS Y ESTILOS DE PIZZERÍAS ///////////////

class Entrega {
    const property pedidoOriginal
    const property precioDelPedido
    const property ejecucion  // Lo que realmente se entregó
    const property precioFinal
    
    method cantidadPizzasEntregadas() = ejecucion.size()
    
    override method toString() = 
        "Entrega: Pedido original(" + pedidoOriginal.pizzas().size() + 
        " pizzas, $" + precioDelPedido + ") -> Ejecutado(" + 
        ejecucion.size() + " pizzas, $" + precioFinal + ")"
}

// PUNTO 3: Estilos de pizzerías

class EstiloPizzeria {
    method procesarPedido(pedido, pizzeria)  // Método abstracto
}

class EstiloIngredienteExtra inherits EstiloPizzeria {
    const property ingredienteExtra
    
    override method procesarPedido(pedido, pizzeria) {
        const pizzasModificadas = pedido.pizzas().map { pizza =>
            const pizzaCopia = self.copiarPizza(pizza)
            pizzaCopia.agregarIngrediente(ingredienteExtra)
            pizzaCopia
        }
        return pizzasModificadas
    }
    
    method copiarPizza(pizza) {
        const nuevaPizza = new Pizza()
        pizza.ingredientes().forEach { ing => nuevaPizza.agregarIngrediente(ing) }
        return nuevaPizza
    }
}

class EstiloResumen inherits EstiloPizzeria {
    
    override method procesarPedido(pedido, pizzeria) {
        const pizzas = pedido.pizzas()
        
        if (pizzas.isEmpty()) return []
        
        // Crear una pizza compuesta con todas las pizzas del pedido
        const pizzaCompuesta = new PizzaCompuesta()
        
        // Intentar agregar todas las pizzas
        pizzas.forEach { pizza =>
            if (pizzaCompuesta.puedeAgregarPizza(pizza)) {
                pizzaCompuesta.agregarPizza(pizza)
            } else {
                // Si no se pueden agregar todas, no se puede realizar la entrega
                self.error("No se puede realizar la entrega: demasiadas pizzas para una compuesta")
            }
        }
        
        return [pizzaCompuesta]
    }
}

class EstiloLaPreferida inherits EstiloPizzeria {
    const property pizzaPreferida
    
    override method procesarPedido(pedido, pizzeria) {
        return pedido.pizzas().map { pizza =>
            const pizzaCompuesta = new PizzaCompuesta()
            pizzaCompuesta.agregarPizza(pizza)
            pizzaCompuesta.agregarPizza(self.copiarPizza(pizzaPreferida))
            pizzaCompuesta
        }
    }
    
    method copiarPizza(pizza) {
        const nuevaPizza = new Pizza()
        pizza.ingredientes().forEach { ing => nuevaPizza.agregarIngrediente(ing) }
        return nuevaPizza
    }
}

class EstiloLaCombineta inherits EstiloPizzeria {
    
    override method procesarPedido(pedido, pizzeria) {
        const pizzas = pedido.pizzas()
        
        if (pizzas.size() < 2) return pizzas  // Si hay menos de 2, no se puede combinar
        
        const combinaciones = []
        
        // Combinar cada pizza con la siguiente
        (0..(pizzas.size() - 2)).forEach { i =>
            const pizzaCompuesta = new PizzaCompuesta()
            pizzaCompuesta.agregarPizza(pizzas.get(i))
            pizzaCompuesta.agregarPizza(pizzas.get(i + 1))
            combinaciones.add(pizzaCompuesta)
        }
        
        return combinaciones
    }
}

class EstiloNormal inherits EstiloPizzeria {
    
    override method procesarPedido(pedido, pizzeria) {
        return pedido.pizzas()  // Entrega exactamente lo que se pidió
    }
}

///////////////  PIZZERÍAS ESPECÍFICAS ///////////////

object pizzeriaKetruchy {
    const pizzeria = new Pizzeria(
        nombre = "Ketruchy", 
        costoBase = 180, 
        factorChetez = 1.3,
        estilo = new EstiloIngredienteExtra(ingredienteExtra = "palmito")
    )
    
    method pizzeria() = pizzeria
}

object pizzeriaWalterWhite {
    const pizzeria = new Pizzeria(
        nombre = "Walter White", 
        costoBase = 220, 
        factorChetez = 1.1,
        estilo = new EstiloIngredienteExtra(ingredienteExtra = "harina")
    )
    
    method pizzeria() = pizzeria
}

object pizzeriaChimPum {
    const pizzeria = new Pizzeria(
        nombre = "ChimPum", 
        costoBase = 200, 
        factorChetez = 1.4,
        estilo = new EstiloResumen()
    )
    
    method pizzeria() = pizzeria
}

object pizzeriaElCuartucho {
    const pizzaPreferida = new Pizza()
    
    method initialize() {
        pizzaPreferida.agregarIngrediente("muzzarella")
        pizzaPreferida.agregarIngrediente("cebolla")
        pizzaPreferida.agregarIngrediente("jamón")
    }
    
    const pizzeria = new Pizzeria(
        nombre = "El Cuartucho", 
        costoBase = 250, 
        factorChetez = 1.2,
        estilo = new EstiloLaPreferida(pizzaPreferida = pizzaPreferida)
    )
    
    method pizzeria() = pizzeria
}

object pizzeriaGuarrin {
    const pizzeria = new Pizzeria(
        nombre = "Guarrin", 
        costoBase = 190, 
        factorChetez = 1.25,
        estilo = new EstiloLaCombineta()
    )
    
    method pizzeria() = pizzeria
}

object pizzeriaElKraken {
    const pizzeria = new Pizzeria(
        nombre = "El Kraken", 
        costoBase = 170, 
        factorChetez = 1.15,
        estilo = new EstiloNormal()
    )
    
    method pizzeria() = pizzeria
}

///////////////  CLIENTES ESPECÍFICOS ///////////////

object clienteMati {
    const cliente = new ClienteManoso(
        nombre = "Mati",
        ingredienteOdiado = "palmito"
    )
    
    method cliente() = cliente
}

object clienteExigente {
    const cliente = new ClienteSuperExigente(nombre = "Cliente Exigente")
    method cliente() = cliente
}

object clienteHumildito {
    const cliente = new ClienteHumilde(nombre = "Cliente Humilde")
    method cliente() = cliente
}
