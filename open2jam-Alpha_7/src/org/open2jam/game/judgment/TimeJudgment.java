
package org.open2jam.game.judgment;

import org.open2jam.render.entities.NoteEntity;
import org.open2jam.parsers.utils.Logger;
import java.util.logging.Level;


/**
 * Judge hits by time.
 * @author dttvb
 */
public class TimeJudgment extends AbstractJudgmentStrategy {

    private static final double BAD_THRESHOULD = 173;
    private static final double GOOD_THRESHOULD = 125;
    private static final double COOL_THRESHOULD = 41;
    
    @Override
    public boolean accept(NoteEntity note) { 
        Logger.global.log(Level.INFO, "hitTime", note.getHitTime());
        return note.getHitTime() <= BAD_THRESHOULD;
    }

    @Override
    public boolean missed(NoteEntity note) {
        return note.getHitTime() < -BAD_THRESHOULD;
    }

    @Override
    public JudgmentResult judge(NoteEntity note) {
        double hit = Math.abs(note.getHitTime());
        if (hit <= COOL_THRESHOULD) return JudgmentResult.COOL;
        if (hit <= GOOD_THRESHOULD) return JudgmentResult.GOOD;
        if (hit <= BAD_THRESHOULD) return JudgmentResult.BAD;
        return JudgmentResult.MISS;
    }
    
}
