#ifndef UDESTROYER_H
#define UDESTROYER_H

//#include "utilite/UtiLiteExp.h" // DLL export/import defines

/**
 * This class is used to delete a dynamically created
 * objects. It was mainly designed to remove dynamically created Singleton.
 * Created on the stack of a Singleton, when the
 * application is finished, his destructor make sure that the 
 * Singleton is deleted.
 *
 */
template <class T>
class UDestroyer
{
public:
	/**
	 * The constructor. Set the doomed object (take ownership of the object). The object is deleted
	 * when this object is deleted.
	 */
    UDestroyer(T* doomed = 0)  : doomed_(doomed) {}
    
    ~UDestroyer()
    {
        if(doomed_)
        {
            delete doomed_;
            doomed_ = 0;
        }
    }

    /**
	 * Set the doomed object. If a doomed object is already set, the function returns false.
	 * @param doomed the doomed object
	 * @return false if an object is already set and the new object is not null, otherwise true
	 */
    bool setDoomed(T* doomed)
	{
    	if(doomed_ && doomed)
    	{
    		return false;
    	}
		doomed_ = doomed;
		return true;
	}

private:
    // Prevent users from making copies of a 
    // Destroyer to avoid double deletion:
    UDestroyer(const UDestroyer<T>&);
    void operator=(const UDestroyer<T>&);

private:
    T* doomed_;
};

#endif // UDESTROYER_H
