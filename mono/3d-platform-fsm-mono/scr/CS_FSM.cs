using Godot;
using System;
using System.Collections;

namespace StateMachine
{
	public struct State
	{
		public State(int id, string name)
		{
			ID = id;
			this.name = name;
			onEnter = "OnEnter" + name;
			onUpdate = "OnUpdate" + name;
			onExit = "onExit" + name;
		}
		public int ID;
		public string name;
		public string onEnter, onUpdate, onExit;

		// public delegate OnEnter;

	}

	public struct FSM
	{

		public FSM(String[] statesInfo, Godot.Object instance)
		{
			int size = statesInfo.Length;
			states = new State[size];
			currentState = new State(-1, "test");
			function = new FuncRef();
			funcUpdate = new FuncRef();
			function.SetInstance(instance);
			funcUpdate.SetInstance(instance);
			for (int i = 0; i < size; i++)
			{
				RegisterState(statesInfo[i], i);
			}
			ChangeState(statesInfo[0], true);
		}
		State[] states;
		State currentState;

		FuncRef function, funcUpdate;


		public void ChangeState(string stateName, bool first = false)
		{
			State to = states[0];
			foreach (State st in states)
			{
				if (st.name.Equals(stateName))
				{
					to = st;
					break;
				}
			}
			if (!first)
			{
				function.SetFunction(currentState.onExit);
				function.CallFunc();
			}
			currentState = to;
			funcUpdate.SetFunction(currentState.onUpdate);
			function.SetFunction(currentState.onEnter);
			function.CallFunc();
		}

		void RegisterState(string name, int id)
		{
			State st = new State(id, name);
			states[id] = st;
			GD.Print("STATEs: " + st.name + "\nID: " + st.ID);
		}

		public string GetCurrentStateName()
		{
			return currentState.name;
		}


		public void Update()
		{
			funcUpdate.CallFunc();
		}
	}

}

