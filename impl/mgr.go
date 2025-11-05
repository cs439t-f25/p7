package impl

// your implementation details go here

import "errors"
import "github.com/cs439t-f25/layer2"

type Impl struct {
	sw *layer2.Switch
}

func NewMgr(sw *layer2.Switch) (layer2.Mgr, error) {
	if sw == nil {
		return nil, errors.New("sw cannot be nil")
	}
	return &Impl{sw: sw}, nil
}

func (imp *Impl) IfConfig(mac layer2.MacAddr, ifName string) error {
	return errors.New("not implemented")
}

func (imp *Impl) Connect(myPort uint16, destPort uint16, destName string) (*layer2.Connection, error) {
	return nil, errors.New("not implemented")
}

func (imp *Impl) Listen(port uint16) (*layer2.Connection, error) {
	return nil, errors.New("not implemented")
}


