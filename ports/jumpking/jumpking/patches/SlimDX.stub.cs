using System;
using System.Collections.Generic;

[assembly: System.Reflection.AssemblyVersion("4.0.13.43")]
[assembly: System.Reflection.AssemblyFileVersion("4.0.13.43")]

namespace SlimDX
{
    // DirectInput methods return Result values that the game ignores.
    public struct Result
    {
        public int Code;
        public bool IsSuccess { get { return true; } }
        public bool IsFailure { get { return false; } }
    }
}

namespace SlimDX.DirectInput
{
    public enum DeviceClass { All = 0, AttachedOnly = 1, ForceFeedback = 2 }
    [Flags]
    public enum DeviceEnumerationFlags
    {
        AllAttached = 0x00000000,
        AttachedOnly = 0x00000001,
        ForceFeedback = 0x00000100,
        IncludeAliases = 0x00010000,
        IncludePhantoms = 0x00020000,
        IncludeHidden = 0x00040000,
    }
    public enum ObjectDeviceType
    {
        Other = 0x00, Axis = 0x01, Button = 0x02, PointOfView = 0x03,
        Collection = 0x04, NoData = 0x05,
    }

    public class DirectInputException : Exception
    {
        public DirectInputException() { }
        public DirectInputException(string message) : base(message) { }
    }

    /// <summary>
    /// Stub DirectInput that reports no devices, so the game falls back to
    /// MonoGame's GamePad/Keyboard input and never touches native dinput8.
    /// </summary>
    public class DirectInput : IDisposable
    {
        public DirectInput() { }
        public IList<DeviceInstance> GetDevices(DeviceClass deviceClass, DeviceEnumerationFlags flags)
        {
            return new List<DeviceInstance>();
        }
        public void Dispose() { }
    }

    public class DeviceInstance
    {
        public Guid InstanceGuid { get; set; }
        public Guid ProductGuid { get; set; }
        public string ProductName { get; set; }
        public string InstanceName { get; set; }
        public bool HumanInterfaceDevice { get; set; }
    }

    public struct DeviceObjectInstance
    {
        public ObjectDeviceType ObjectType { get; set; }
    }

    public class Capabilities
    {
        public int ButtonCount { get; set; }
    }

    public class DeviceProperties
    {
        public string InstanceName { get; set; }
    }

    public class ObjectProperties
    {
        public void SetRange(int minimum, int maximum) { }
    }

    public class Device : IDisposable
    {
        public Result Acquire() { return new Result(); }
        public Result Unacquire() { return new Result(); }
        public IList<DeviceObjectInstance> GetObjects() { return new List<DeviceObjectInstance>(); }
        public ObjectProperties GetObjectPropertiesById(int objectId) { return new ObjectProperties(); }
        public Capabilities Capabilities { get; set; }
        public DeviceInstance Information { get; set; }
        public DeviceProperties Properties { get; set; }
        public void Dispose() { }
    }

    public class Joystick : Device
    {
        public Joystick(DirectInput directInput, Guid instanceGuid) { }
        public JoystickState GetCurrentState() { return new JoystickState(); }
    }

    public class JoystickState
    {
        public int X { get; set; }
        public int Y { get; set; }
        public int Z { get; set; }
        public int RotationX { get; set; }
        public int RotationY { get; set; }
        public int RotationZ { get; set; }
        public bool[] GetButtons() { return new bool[0]; }
        public int[] GetPointOfViewControllers() { return new int[0]; }
    }
}
