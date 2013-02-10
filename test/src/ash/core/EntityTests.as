package ash.core
{
	import asunit.framework.IAsync;

	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.hasItems;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;
	import org.hamcrest.object.nullValue;
	import org.hamcrest.object.sameInstance;

	import flash.geom.Point;




	public class EntityTests
	{
		[Inject]
		public var async : IAsync;

		private var entity : Entity;

		[Before]
		public function createEntity() : void
		{
			entity = new Entity();
		}

		[After]
		public function clearEntity() : void
		{
			entity = null;
		}

		[Test]
		public function addReturnsReferenceToEntity() : void
		{
			var component : MockComponent = new MockComponent();
			var e : Entity = entity.add( component );
			assertThat( e, sameInstance( entity ) );
		}

		[Test]
		public function canStoreAndRetrieveComponent() : void
		{
			var component : MockComponent = new MockComponent();
			entity.add( component );
			assertThat( entity.get( MockComponent ), sameInstance( component ) );
		}

		[Test]
		public function canStoreAndRetrieveMultipleComponents() : void
		{
			var component1 : MockComponent = new MockComponent();
			entity.add( component1 );
			var component2 : MockComponent2 = new MockComponent2();
			entity.add( component2 );
			assertThat( entity.get( MockComponent ), sameInstance( component1 ) );
			assertThat( entity.get( MockComponent2 ), sameInstance( component2 ) );
		}

		[Test]
		public function canReplaceComponent() : void
		{
			var component1 : MockComponent = new MockComponent();
			entity.add( component1 );
			var component2 : MockComponent = new MockComponent();
			entity.add( component2 );
			assertThat( entity.get( MockComponent ), sameInstance( component2 ) );
		}

		[Test]
		public function canStoreBaseAndExtendedComponents() : void
		{
			var component1 : MockComponent = new MockComponent();
			entity.add( component1 );
			var component2 : MockComponentExtended = new MockComponentExtended();
			entity.add( component2 );
			assertThat( entity.get( MockComponent ), sameInstance( component1 ) );
			assertThat( entity.get( MockComponentExtended ), sameInstance( component2 ) );
		}

		[Test]
		public function canStoreExtendedComponentAsBaseType() : void
		{
			var component : MockComponentExtended = new MockComponentExtended();
			entity.add( component, MockComponent );
			assertThat( entity.get( MockComponent ), sameInstance( component ) );
		}

		[Test]
		public function getReturnNullIfNoComponent() : void
		{
			assertThat( entity.get( MockComponent ), nullValue() );
		}

		[Test]
		public function willRetrieveAllComponents() : void
		{
			var component1 : MockComponent = new MockComponent();
			entity.add( component1 );
			var component2 : MockComponent2 = new MockComponent2();
			entity.add( component2 );
			var all : Array = entity.getAll();
			assertThat( all.length, equalTo( 2 ) );
			assertThat( all, hasItems( component1, component2 ) );

		}

		[Test]
		public function hasComponentIsFalseIfComponentTypeNotPresent() : void
		{
			entity.add( new MockComponent2() );
			assertThat( entity.has( MockComponent ), isFalse() );
		}

		[Test]
		public function hasComponentIsTrueIfComponentTypeIsPresent() : void
		{
			entity.add( new MockComponent() );
			assertThat( entity.has( MockComponent ), isTrue() );
		}

		[Test]
		public function canRemoveComponent() : void
		{
			var component : MockComponent = new MockComponent();
			entity.add( component );
			entity.remove( MockComponent );
			assertThat( entity.has( MockComponent ), isFalse() );
		}

		[Test]
		public function storingComponentTriggersAddedSignal() : void
		{
			var component : MockComponent = new MockComponent();
			entity.componentAdded.add( async.add() );
			entity.add( component );
		}

		[Test]
		public function removingComponentTriggersRemovedSignal() : void
		{
			var component : MockComponent = new MockComponent();
			entity.add( component );
			entity.componentRemoved.add( async.add() );
			entity.remove( MockComponent );
		}

		[Test]
		public function componentAddedSignalContainsCorrectParameters() : void
		{
			var component : MockComponent = new MockComponent();
			entity.componentAdded.add( async.add( testSignalContent, 10 ) );
			entity.add( component );
		}

		[Test]
		public function componentRemovedSignalContainsCorrectParameters() : void
		{
			var component : MockComponent = new MockComponent();
			entity.add( component );
			entity.componentRemoved.add( async.add( testSignalContent, 10 ) );
			entity.remove( MockComponent );
		}

		[Test]
		public function cloneIsNewReference() : void
		{
			entity.add( new MockComponent() );
			var clone : Entity = entity.clone();
			assertThat( clone == entity, isFalse() );
		}

        [Test]
        public function cloneHasChildComponent() : void
        {
            entity.add( new MockComponent() );
            var clone : Entity = entity.clone();
            assertThat( clone.has( MockComponent ), isTrue() );
        }

        [Test]
        public function cloneHasChildComponentAsBaseType() : void
        {
            entity.add( new MockComponentExtended(), MockComponent );
            var clone : Entity = entity.clone();
            assertThat( clone.has( MockComponent ), isTrue() );
        }

		[Test]
		public function cloneChildComponentIsNewReference() : void
		{
			entity.add( new MockComponent() );
			var clone : Entity = entity.clone();
			assertThat( clone.get( MockComponent ) == entity.get( MockComponent ), isFalse() );
		}

		[Test]
		public function cloneChildComponentHasSameProperties() : void
		{
			var component : MockComponent = new MockComponent();
			component.value = 5;
			entity.add( component );
			var clone : Entity = entity.clone();
			assertThat( clone.get( MockComponent ).value, equalTo( 5 ) );
		}

		[Test]
		public function cloneChildComponentWithCloneMethodUsesThatMethod() : void
		{
			var component : MockClonableComponent = new MockClonableComponent();
			component.array = [ 1, 2 ];
			entity.add( component );
			var clone : Entity = entity.clone();
			assertThat( clone.get( MockClonableComponent ).array, not( sameInstance( component.array ) ) );
			assertThat( clone.get( MockClonableComponent ).array, array( 1, 2 ) );
		}

		[Test]
		public function cloneChildComponentWithCloneablePropertyClonesThatProperty() : void
		{
			var component : MockComponentWithClonableProperty = new MockComponentWithClonableProperty();
			component.point = new Point( 1, 2 );
			entity.add( component );
			var clone : Entity = entity.clone();
			assertThat( clone.get( MockComponentWithClonableProperty ).point, not( sameInstance( component.point ) ) );
			assertThat( clone.get( MockComponentWithClonableProperty ).point.x, equalTo( 1 ) );
			assertThat( clone.get( MockComponentWithClonableProperty ).point.y, equalTo( 2 ) );
		}
		
		private function testSignalContent( signalEntity : Entity, componentClass : Class ) : void
		{
			assertThat( signalEntity, sameInstance( entity ) );
			assertThat( componentClass, sameInstance( MockComponent ) );
		}
	}
}

import flash.geom.Point;
class MockComponent
{
	public var value : int;
}

class MockComponent2
{
	public var value : String;
}

class MockComponentExtended extends MockComponent
{
	public var other : int;
}

class MockClonableComponent
{
	public var array : Array;
	
	public function clone() : MockClonableComponent
	{
		var other : MockClonableComponent = new MockClonableComponent();
		other.array = new Array();
		for each( var value : * in array )
		{
			other.array.push( value );
		}
		return other;
	}
}

class MockComponentWithClonableProperty
{
	public var point : Point;
}