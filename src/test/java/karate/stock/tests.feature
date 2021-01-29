Feature: Simple Stock management

  Background:
    * url baseUrl + "/v2"
    * def password = "a_funny_horse**jumps_high778"
    * def name = 'Bananas'
    * def unitType = 'PIECE'
    * def quantity = 42.0
    * def pricePerUnit = 4.2
    * def description = "this is a lovely piece of produce"
    * def sustainablyProduced = true
    * def certificates =  [ "Test", "Demeter" ]
    * def originCategory = "LOCAL"
    * def producer = "Farmer Joe"
    * def supplier = "Cargo bike dude"
    * def orderDate = "2021-01-24"
    * def deliveryDate = "2021-01-24"
    * def stockStatus = "INSTOCK"
    * def defaultStockBody =
    """
     { 
       name: #(name),
       unitType: #(unitType),
       quantity: #(quantity),
       pricePerUnit: #(pricePerUnit),
       description: #(description),
       sustainablyProduced: #(sustainablyProduced),
       certificates: #(certificates),
       originCategory: #(originCategory),
       producer: #(producer),
       supplier: #(supplier),
       orderDate: #(orderDate),
       deliveryDate: #(deliveryDate),
       stockStatus: #(stockStatus)}
    """
    * def nameChanged = 'Avocados'
    * def unitTypeChanged = 'WEIGHT'
    * def quantityChanged = 110.0
    * def pricePerUnitChanged = 4.2
    * def descriptionChanged = "this is a lovely piece of produce with a different description"
    * def sustainablyProducedChanged = false
    * def certificatesChanged =  [ "Not Demeter" ]
    * def originCategoryChanged = "SUPRAREGIONAL"
    * def producerChanged = "Farmer Bob"
    * def supplierChanged = "Not the Cargo bike dude"
    * def orderDateChanged = "2020-01-20"
    * def deliveryDateChanged = "2020-01-20"
    * def stockStatusChanged = "SPOILSSOON"
    * def defaultStockBodyChanged = 
    """
    { 
      name: #(nameChanged),
      unitType: #(unitTypeChanged),
      quantity: #(quantityChanged),
      pricePerUnit: #(pricePerUnitChanged),
      description: #(descriptionChanged),
      sustainablyProduced: #(sustainablyProducedChanged),
      certificates: #(certificatesChanged),
      originCategory: #(originCategoryChanged), 
      producer: #(producerChanged),
      supplier: #(supplierChanged),
      orderDate: #(orderDateChanged),
      deliveryDate: #(deliveryDateChanged),
      stockStatus: #(stockStatusChanged)
    }
    """
    * def filterByStatus =
    """
    function(arr, status) {
      if (arr === undefined || arr === null || status === undefined || status === null) {
        return null;
      }
      var filtered = []
      for (var i = 0; i < arr.length; i++) {
        if (arr[i].stockStatus === status) {
          filtered.push(arr[i]);
        }
      }
      return filtered;
    }
    """

  Scenario: GET returns an empty list if no stock exists
    # Get token
    Given path 'auth', 'login'
    And request { username: 'member',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    Given path '/stock'
    And header Authorization = "Bearer " + token
    When method GET
    Then status 200
    And assert response.items.length == 0

  Scenario: Create a stock item
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create stock item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And match response contains { id: '#uuid', name: #(name), unitType: #(unitType), quantity: #(quantity), pricePerUnit: #(pricePerUnit), stockStatus: #(stockStatus) }
    And def stockId = response.id

    # Get the item that was just created
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    When method GET
    Then status 200
    And match response contains defaultStockBody
    And match response.isDeleted == false

  Scenario: Update a stock item with all values
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Update this stock item
    Given path 'stock', stockId
    And header Authorization = "Bearer " + token
    And request defaultStockBodyChanged
    When method PATCH
    Then status 200
    And match response contains defaultStockBodyChanged

    # Check that patch was successful
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    When method GET
    Then status 200
    And match response contains defaultStockBodyChanged
    And match response.isDeleted == false

  Scenario: Patch of only the name works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch name of this item
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And def nameChanged = "Juniper"
    And request { name: #(nameChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(nameChanged), unitType: #(unitType), quantity: #(quantity), pricePerUnit: #(pricePerUnit) }

  Scenario: Patch of only the UnitType works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch UnitType
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And def unitTypeChanged = "WEIGHT"
    And request { unitType: #(unitTypeChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitTypeChanged), quantity: #(quantity), pricePerUnit: #(pricePerUnit) }

  Scenario: Patch of only the quantity works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch quantity
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And def quantityChanged = 120.0
    And request { quantity: #(quantityChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantityChanged), pricePerUnit: #(pricePerUnit) }

  Scenario: Patch of only the pricePerUnit works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch pricePerUnit
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And def pricePerUnitChanged = 1.22
    And request { pricePerUnit: #(pricePerUnitChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantity), pricePerUnit: #(pricePerUnitChanged) }

  Scenario: Patch of only the description works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch description
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And request { description: #(descriptionChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantity), description: #(descriptionChanged) }
  
  Scenario: Patch of only the stockStatus works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch stockStatus
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And request { stockStatus: #(stockStatusChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantity), stockStatus: #(stockStatusChanged) }

  Scenario: Patch of only sustainablyProduced works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch sustainablyProduced
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And request { sustainablyProduced: #(sustainablyProducedChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantity), sustainablyProduced: #(sustainablyProducedChanged) }

  Scenario: Patch of only certificates works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch certificates
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And request { certificates: #(certificatesChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantity), certificates: #(certificatesChanged) }

  Scenario: Patch of only originCategory works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch originCategory
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And request { originCategory: #(originCategoryChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantity), originCategory: #(originCategoryChanged) }

  Scenario: Patch of only producer works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch producer
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And request { producer: #(producerChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantity), producer: #(producerChanged) }

  Scenario: Patch of only supplier works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch supplier
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And request { supplier: #(supplierChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantity), supplier: #(supplierChanged) }

  Scenario: Patch of only orderDate works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch orderDate
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And request { orderDate: #(orderDateChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantity), orderDate: #(orderDateChanged) }

  Scenario: Patch of only deliveryDate works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Only patch deliveryDate
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And request { deliveryDate: #(deliveryDateChanged) }
    When method PATCH
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantity), deliveryDate: #(deliveryDateChanged) }

  Scenario: Soft Delete works
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId = response.id

    # Delete this item
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    When method DELETE
    Then status 204

    # Get item after delete
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    When method GET
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantity), pricePerUnit: #(pricePerUnit) }
    And match response.isDeleted == true

  Scenario: POST can create an item without a description
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request { name: "test", unitType: "PIECE", quantity: 10.0, pricePerUnit: 5.0, stockStatus: "INSTOCK" }
    When method POST
    Then status 201

  Scenario: Cannot create item with unitType PIECE and fractional quantity
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request { name: #(name), unitType: "PIECE", quantity: 14.5, pricePerUnit: 4.2 }
    When method POST
    Then status 400
    And response.errorCode == 400008

  Scenario: POST with same item name is possible
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # First Post
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And assert response.id != null
    And assert response.name == name
    And assert response.unitType == unitType
    And assert response.quantity == quantity
    And assert response.pricePerUnit == pricePerUnit
    And def stockId = response.id

    # Second Post
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And assert response.id != stockId
    And assert response.name == name
    And assert response.unitType == unitType
    And assert response.quantity == quantity
    And assert response.pricePerUnit == pricePerUnit

  Scenario: Cannot PATCH an item with unitType PIECE and fractional quantity
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And assert response.id != null
    And assert response.name == name
    And assert response.unitType == unitType
    And assert response.quantity == quantity
    And assert response.pricePerUnit == pricePerUnit
    And def stockId = response.id

    # Patch it
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And request { unitType: "PIECE", quantity: 7.4 }
    When method PATCH
    Then status 400
    And response.errorCode == 400008

    # Check that no values were updated
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    When method GET
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: #(unitType), quantity: #(quantity), pricePerUnit: #(pricePerUnit) }
    And match response.isDeleted == false

  Scenario: Cannot PATCH fractional quantity of item with unitType PIECE
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And assert response.id != null
    And assert response.name == name
    And assert response.unitType == unitType
    And assert response.quantity == quantity
    And assert response.pricePerUnit == pricePerUnit
    And def stockId = response.id

    # Patch Item
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And request { quantity: 7.4 }
    When method PATCH
    Then status 400
    And response.errorCode == 400008

    # Check that no values were updated
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    When method GET
    Then status 200
    And match response contains { id: #(stockId), name: #(name), unitType: "PIECE", quantity: #(quantity), pricePerUnit: #(pricePerUnit) }
    And match response.isDeleted == false

  Scenario: Cannot PATCH a soft deleted item
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create Item
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And assert response.id != null
    And assert response.name == name
    And assert response.unitType == unitType
    And assert response.quantity == quantity
    And assert response.pricePerUnit == pricePerUnit
    And def stockId = response.id

    # Delete it
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    When method DELETE
    Then status 204

    # Check that it can't be patched
    Given path '/stock/' + stockId
    And header Authorization = "Bearer " + token
    And request { name: "Honey" }
    When method PATCH
    Then status 400
    And assert response.errorCode == 400009

  Scenario: GET with no delete parameter does not include deleted items
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create item 1
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId1 = response.id

    # Create item 2
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId2 = response.id

    # Delete item 2
    Given path '/stock/' + stockId2
    And header Authorization = "Bearer " + token
    When method DELETE
    Then status 204

    # GET items
    Given path '/stock'
    And header Authorization = "Bearer " + token
    When method GET
    Then status 200
    And match each response.items contains { isDeleted: false }

  Scenario: GET with delete parameter OMIT does not include deleted items
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create item 1
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId1 = response.id

    # Create item 2
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId2 = response.id

    # Delete item 2
    Given path '/stock/' + stockId2
    And header Authorization = "Bearer " + token
    When method DELETE
    Then status 204

    # GET items
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And param deleted = "OMIT"
    When method GET
    Then status 200
    And match each response.items contains { isDeleted: false }

  Scenario: GET with delete parameter INCLUDE includes deleted and not deleted items
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create item 1
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId1 = response.id

    # Create item 2
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId2 = response.id

    # Delete item 2
    Given path '/stock/' + stockId2
    And header Authorization = "Bearer " + token
    When method DELETE
    Then status 204

    # GET items
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And param deleted = "INCLUDE"
    When method GET
    Then status 200
    And def filterForDeleted = function(x){ return x.isDeleted == true }
    And def filterForNotDeleted = function(x){ return x.isDeleted == false }
    And def deletedItems = karate.filter(response.items, filterForDeleted)
    And def notDeletedItems = karate.filter(response.items, filterForNotDeleted)
    And assert deletedItems.length > 0
    And assert notDeletedItems.length > 0

  Scenario: GET with delete parameter ONLY does not include non-deleted items
    # Get token
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def token = response.token

    # Create item 1
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId1 = response.id

    # Create item 2
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And request defaultStockBody
    When method POST
    Then status 201
    And def stockId2 = response.id

    # Delete item 2
    Given path '/stock/' + stockId2
    And header Authorization = "Bearer " + token
    When method DELETE
    Then status 204

    # GET items
    Given path '/stock'
    And header Authorization = "Bearer " + token
    And param deleted = "ONLY"
    When method GET
    Then status 200
    And match each response.items contains { isDeleted: true }

  Scenario: GET /stock requires authorization
    Given path '/stock'
    When method GET
    Then status 401
    And match response.errorCode == 401005

  Scenario: POST /stock requires authorization
    Given path '/stock'
    And request {}
    When method POST
    Then status 401
    And match response.errorCode == 401005

  Scenario: GET /stock/{id} requires authorization
    Given path '/stock' + "123"
    When method GET
    Then status 401
    And match response.errorCode == 401005

  Scenario: PATCH /stock/{id} requires authorization
    Given path '/stock' + "123"
    And request {}
    When method PATCH
    Then status 401
    And match response.errorCode == 401005

  Scenario: DELETE /stock/{id} requires authorization
    Given path '/stock' + "123"
    When method DELETE
    Then status 401
    And match response.errorCode == 401005

  Scenario: Filtering by status OUTOFSTOCK works
    # Get token for orderer
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def oToken = response.token

    # Create stock item with status ORDERED
    Given path '/stock'
    And header Authorization = "Bearer " + oToken
    And request
    """
    {
      name: #(name),
      unitType: #(unitType),
      quantity: #(quantity),
      pricePerUnit: #(pricePerUnit),
      description: #(description),
      stockStatus: 'OUTOFSTOCK',
     }
    """
    When method POST
    Then status 201

    # Create stock item with status INSTOCK
    Given path '/stock'
    And header Authorization = "Bearer " + oToken
    And request
    """
    {
      name: #(name),
      unitType: #(unitType),
      quantity: #(quantity),
      pricePerUnit: #(pricePerUnit),
      description: #(description),
      stockStatus: 'INSTOCK',
     }
    """
    When method POST
    Then status 201

    # Get token for member
    Given path 'auth', 'login'
    And request { username: 'member',  password: #(password) }
    When method POST
    Then status 200
    And def mToken = response.token

    # A member cannot filter by OUTOFSTOCK
    Given path 'stock'
    And param filterByStatus = "OUTOFSTOCK"
    And header Authorization = "Bearer " + mToken
    When method GET
    Then status 400
    And match response.errorCode == 400020

    # Orderer filters by OUTOFSTOCK
    Given path 'stock'
    And param filterByStatus = "OUTOFSTOCK"
    And header Authorization = "Bearer " + oToken
    When method GET
    Then status 200
    And assert response.items.length > 0
    And match each response.items contains { stockStatus: 'OUTOFSTOCK' }

  Scenario: Filtering by status OUTOFSTOCK and INSTOCK works
    # Get token for orderer
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def oToken = response.token

    # Create stock item with status OUTOFSTOCK
    Given path '/stock'
    And header Authorization = "Bearer " + oToken
    And request
    """
    {
      name: #(name),
      unitType: #(unitType),
      quantity: #(quantity),
      pricePerUnit: #(pricePerUnit),
      description: #(description),
      stockStatus: 'OUTOFSTOCK',
     }
    """
    When method POST
    Then status 201

    # Create stock item with status INSTOCK
    Given path '/stock'
    And header Authorization = "Bearer " + oToken
    And request
    """
    {
      name: #(name),
      unitType: #(unitType),
      quantity: #(quantity),
      pricePerUnit: #(pricePerUnit),
      description: #(description),
      stockStatus: 'INSTOCK',
     }
    """
    When method POST
    Then status 201

    # Get token for member
    Given path 'auth', 'login'
    And request { username: 'member',  password: #(password) }
    When method POST
    Then status 200
    And def mToken = response.token

    # A member cannot filter by OUTOFSTOCK
    Given path 'stock'
    And param filterByStatus = "OUTOFSTOCK,INSTOCK"
    And header Authorization = "Bearer " + mToken
    When method GET
    Then status 400
    And match response.errorCode == 400020

    # Orderer filters by OUTOFSTOCK and INSTOCK
    Given path 'stock'
    And param filterByStatus = "OUTOFSTOCK,INSTOCK"
    And header Authorization = "Bearer " + oToken
    When method GET
    Then status 200
    And assert response.items.length > 0
    And match each response.items contains { stockStatus: '#? _ === "OUTOFSTOCK" || _ === "INSTOCK"' }

  Scenario: A user without role ORDERER does not get items of status "ORDERED" or "OUTOFSTOCK" but an ORDERER sees everything
    # Get token for orderer
    Given path 'auth', 'login'
    And request { username: 'orderer',  password: #(password) }
    When method POST
    Then status 200
    And def oToken = response.token

    # Get token for member
    Given path 'auth', 'login'
    And request { username: 'member',  password: #(password) }
    When method POST
    Then status 200
    And def mToken = response.token

    # Create stock item with status ORDERED
    Given path '/stock'
    And header Authorization = "Bearer " + oToken
    And request
    """
    {
      name: #(name),
      unitType: #(unitType),
      quantity: #(quantity),
      pricePerUnit: #(pricePerUnit),
      description: #(description),
      stockStatus: 'OUTOFSTOCK',
     }
    """
    When method POST
    Then status 201

    # Create stock item with status OUTOFSTOCK
    Given path '/stock'
    And header Authorization = "Bearer " + oToken
    And request
    """
    {
      name: #(name),
      unitType: #(unitType),
      quantity: #(quantity),
      pricePerUnit: #(pricePerUnit),
      description: #(description),
      stockStatus: 'OUTOFSTOCK',
     }
    """
    When method POST
    Then status 201

    # Create stock item with status INSTOCK
    Given path '/stock'
    And header Authorization = "Bearer " + oToken
    And request
    """
    {
      name: #(name),
      unitType: #(unitType),
      quantity: #(quantity),
      pricePerUnit: #(pricePerUnit),
      description: #(description),
      stockStatus: 'INSTOCK',
     }
    """
    When method POST
    Then status 201

    # Create stock item with status SPOILSSOON
    Given path '/stock'
    And header Authorization = "Bearer " + oToken
    And request
    """
    {
      name: #(name),
      unitType: #(unitType),
      quantity: #(quantity),
      pricePerUnit: #(pricePerUnit),
      description: #(description),
      stockStatus: 'SPOILSSOON',
     }
    """
    When method POST
    Then status 201

    # Get the stock as the member
    Given path 'stock'
    And header Authorization = "Bearer " + mToken
    When method GET
    Then status 200
    And assert response.items.length > 0
    And def stockOrdered = filterByStatus(response.items, "ORDERED")
    And def stockOutOfStock = filterByStatus(response.items, "OUTOFSTOCK")
    And def stockInStock = filterByStatus(response.items, "INSTOCK")
    And def stockSpoilsSoon = filterByStatus(response.items, "SPOILSSOON")
    And assert stockOrdered.length == 0
    And assert stockOutOfStock.length == 0
    And assert stockInStock.length > 0
    And assert stockSpoilsSoon.length > 0

    # Get the stock as the orderer
    Given path 'stock'
    And header Authorization = "Bearer " + oToken
    When method GET
    Then status 200
    And assert response.items.length > 0
    And def stockOrdered = filterByStatus(response.items, "ORDERED")
    And def stockOutOfStock = filterByStatus(response.items, "OUTOFSTOCK")
    And def stockInStock = filterByStatus(response.items, "INSTOCK")
    And def stockSpoilsSoon = filterByStatus(response.items, "SPOILSSOON")
    And assert stockOrdered.length > 0
    And assert stockOutOfStock.length > 0
    And assert stockInStock.length > 0
    And assert stockSpoilsSoon.length > 0
